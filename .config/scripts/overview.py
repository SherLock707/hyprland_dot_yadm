#!/usr/bin/env python3

import json
import cairo
import gi
import os
from typing import Dict, List

gi.require_version("Gtk", "3.0")
gi.require_version("Rsvg", "2.0")

from gi.repository import Gtk, Gdk, GLib, Gio, Rsvg
from fabric import Application
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.eventbox import EventBox
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.utils import exec_shell_command
from hyprpy import Hyprland

# Configuration
COLS, ROWS = 5, 2
PERCENT = 78
SUBSTITUTE_CLASS_NAMES = {"vscode": "codium"}
DESKTOP_DIRS = ["/usr/share/applications", os.path.expanduser("~/.local/share/applications")]
TARGET = [Gtk.TargetEntry.new("text/plain", Gtk.TargetFlags.SAME_APP, 0)]

def add_icons_to_clients(clients):
    unique_classes = {c.get("class") for c in clients if c.get("class")}
    class_to_icon = {}
    theme = Gtk.IconTheme.get_default()  # Cache theme lookup
    
    for cls in unique_classes:
        app_name = SUBSTITUTE_CLASS_NAMES.get(cls, cls).lower()
        
        for base in DESKTOP_DIRS:
            try:
                for fname in os.listdir(base):
                    if fname.endswith(".desktop") and app_name in fname.lower():
                        app_info = Gio.DesktopAppInfo.new_from_filename(f"{base}/{fname}")
                        icon = app_info and app_info.get_icon()
                        if icon:
                            if isinstance(icon, Gio.ThemedIcon):
                                info = theme.lookup_icon(icon.get_names()[0], 64, 0)
                                class_to_icon[cls] = info.get_filename()
                            elif isinstance(icon, Gio.FileIcon):
                                class_to_icon[cls] = icon.get_file().get_path()
                            raise StopIteration  # Break out of nested loops
            except (OSError, StopIteration):
                if cls in class_to_icon:
                    break
    
    # Apply icons in single pass
    for client in clients:
        cls = client.get("class")
        if cls in class_to_icon:
            client["icon"] = class_to_icon[cls]
    
    return class_to_icon

class HyprlandClient:
    def __init__(self):
        self.instance = Hyprland()

    def get_data(self):
        workspaces = []
        for ws in self.instance.get_workspaces():
            if ws.id > 0:
                workspaces.append({
                    'id': ws.id, 'name': ws.name, 'monitor': ws.monitor_name,
                    'monitorID': ws.monitor.id, 'windows': ws.window_count
                })
        
        clients = []
        for cl in self.instance.get_windows():
            clients.append({
                'address': cl.address, 'at': [cl.position_x, cl.position_y],
                'size': [cl.width, cl.height], 'workspace': {'id': cl.workspace_id, 'name': cl.workspace_name},
                'floating': cl.is_floating, 'class': cl.wm_class, 'title': cl.title, 'pid': cl.pid
            })
        
        active_ws = self.instance.get_active_workspace()
        monitors = []
        for mon in self.instance.get_monitors():
            monitors.append({'id': mon.id, 'name': mon.name, 'width': mon.width, 'height': mon.height})
        
        return workspaces, clients, {'id': active_ws.id}, monitors

class DraggableWindow(EventBox):
    def __init__(self, client: Dict, width: int, height: int, overview):
        super().__init__()
        self.client = client
        self.overview = overview
        self.address = client.get("address", "")
        self.is_dragging = False
        self.drag_started = False
        self.press_time = 0
        self.press_pos = (0, 0)
        
        self.set_size_request(width, height)
        self._setup_content(width, height)
        self._setup_drag_drop()
        self._setup_events()

    def _setup_content(self, width, height):
        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=1)
        content.get_style_context().add_class("workspace-content")
        
        # Title and class labels
        max_chars = max(5, width // 8)
        title = (self.client.get("title", "") or self.client.get("class", "Unknown"))[:max_chars]
        
        if height > 25:
            title_label = Gtk.Label(label=title + ("..." if len(title) == max_chars else ""))
            title_label.get_style_context().add_class("window-title")
            title_label.set_halign(Gtk.Align.CENTER)
            content.add(title_label)
        
        if height > 45:
            class_label = Gtk.Label(label=self.client.get("class", "Unknown")[:max_chars])
            class_label.get_style_context().add_class("window-class")
            class_label.set_halign(Gtk.Align.CENTER)
            content.add(class_label)
        
        # SVG icon
        self.svg_handle = None
        svg_path = self.client.get("icon")
        if svg_path:
            try:
                self.svg_handle = Rsvg.Handle.new_from_file(svg_path)
                drawing_area = Gtk.DrawingArea()
                drawing_area.set_margin_top(int(height * 0.03))
                drawing_area.set_has_window(False)
                icon_size = min(width, height) // 3
                drawing_area.set_size_request(icon_size, icon_size)
                drawing_area.connect("draw", self._draw_svg)
                content.add(drawing_area)
            except Exception as e:
                print(f"Error loading SVG: {e}")
        
        self.add(content)
        self._update_style()

    def _setup_drag_drop(self):
        self.drag_source_set(Gdk.ModifierType.BUTTON1_MASK, TARGET, Gdk.DragAction.MOVE)
        self.connect("drag-data-get", lambda w, ctx, data, info, time: data.set_text(self.address, len(self.address)))
        self.connect("drag-begin", self._on_drag_begin)
        self.connect("drag-end", self._on_drag_end)

    def _setup_events(self):
        self.connect("button-press-event", self._on_button_press)
        self.connect("button-release-event", self._on_button_release)
        self.connect("enter-notify-event", self._on_enter)
        self.connect("leave-notify-event", self._on_leave)
        self.set_events(self.get_events() | Gdk.EventMask.POINTER_MOTION_MASK)

    def _update_style(self):
        ctx = self.get_style_context()
        ctx.remove_class("window-floating")
        ctx.remove_class("window-floating-hover")
        ctx.remove_class("window-tiled")
        ctx.remove_class("window-tiled-hover")
        
        if self.client.get("floating", False):
            ctx.add_class("window-floating")
        else:
            ctx.add_class("window-tiled")

    def _on_drag_begin(self, widget, context):
        self.is_dragging = True
        self.drag_started = True
        surface = self._create_drag_surface()
        Gtk.drag_set_icon_surface(context, surface)

    def _on_drag_end(self, widget, context):
        self.is_dragging = False
        GLib.timeout_add(100, lambda: setattr(self, 'drag_started', False))

    def _on_button_press(self, widget, event):
        if event.button == 1:
            self.press_time = event.time
            self.press_pos = (event.x, event.y)
            return True
        elif event.button == 3:  # Right click - switch to workspace
            try:
                ws_id = self.client.get("workspace", {}).get("id", 1)
                exec_shell_command(f"hyprctl dispatch workspace {ws_id}")
                self.overview.close()
            except Exception as e:
                print(f"Error switching workspace: {e}")
            return True
        return False

    def _on_button_release(self, widget, event):
        if event.button == 1 and self.press_time > 0:
            time_diff = event.time - self.press_time
            dx = abs(event.x - self.press_pos[0])
            dy = abs(event.y - self.press_pos[1])
            
            if not self.drag_started and dx <= 5 and dy <= 5 and time_diff < 500:
                try:
                    ws_id = self.client.get("workspace", {}).get("id", 1)
                    exec_shell_command(f"hyprctl dispatch workspace {ws_id}")
                    exec_shell_command(f"hyprctl dispatch focuswindow address:{self.address}")
                    self.overview.close()
                except Exception as e:
                    print(f"Error focusing window: {e}")
            self.press_time = 0
        return True

    def _on_enter(self, widget, event):
        if not self.is_dragging:
            ctx = self.get_style_context()
            ctx.remove_class("window-floating")
            ctx.remove_class("window-tiled")
            if self.client.get("floating", False):
                ctx.add_class("window-floating-hover")
            else:
                ctx.add_class("window-tiled-hover")
        return False

    def _on_leave(self, widget, event):
        if not self.is_dragging:
            self._update_style()
        return False

    def _draw_svg(self, widget, cr):
        if not self.svg_handle:
            return False
        
        width = widget.get_allocated_width()
        height = widget.get_allocated_height()
        dim = self.svg_handle.get_dimensions()
        
        scale = min(width / dim.width, height / dim.height)
        offset_x = (width - dim.width * scale) / 2
        offset_y = (height - dim.height * scale) / 2
        
        cr.translate(offset_x, offset_y)
        cr.scale(scale, scale)
        self.svg_handle.render_cairo(cr)
        return False

    def _create_drag_surface(self):
        alloc = self.get_allocation()
        surface = cairo.ImageSurface(cairo.Format.ARGB32, alloc.width, alloc.height)
        cr = cairo.Context(surface)
        cr.set_source_rgba(0, 0, 0, 0)
        cr.rectangle(0, 0, alloc.width, alloc.height)
        cr.fill()
        self.draw(cr)
        return surface

class WorkspaceDropZone(EventBox):
    def __init__(self, workspace: Dict, clients: List[Dict], is_active: bool, 
                 overview, width: int, height: int, monitor_info: Dict):
        super().__init__()
        self.workspace = workspace
        self.workspace_id = workspace.get("id", 0)
        self.overview = overview
        self.monitor_info = monitor_info
        self.is_active = is_active
        
        self.padding = 2
        self.header_height = 2
        self.content_width = width - (self.padding * 2)
        self.content_height = height - (self.padding * 2) - self.header_height
        
        self.set_size_request(width, height)
        self._setup_drag_drop()
        self._create_content(clients)
        self._update_style()
        self.connect("button-press-event", self._on_click)

    def _setup_drag_drop(self):
        self.drag_dest_set(Gtk.DestDefaults.ALL, TARGET, Gdk.DragAction.MOVE)
        self.connect("drag-data-received", self._on_drag_received)
        self.connect("drag-motion", self._on_drag_motion)
        self.connect("drag-leave", self._on_drag_leave)

    def _create_content(self, clients: List[Dict]):
        main_container = Box(orientation="v", spacing=2)
        main_container.get_style_context().add_class("workspace-content")
        
        # Header
        header = Box(orientation="h", spacing=8)
        ws_name = self.workspace.get("name", str(self.workspace_id))
        header_label = Label(label=f"{ws_name}")
        header_label.get_style_context().add_class("workspace-header")
        header_label.set_halign(Gtk.Align.START)
        header.add(header_label)
        
        workspace_clients = [c for c in clients if c.get("workspace", {}).get("id") == self.workspace_id]
        count_label = Label(label=f"({len(workspace_clients)})")
        count_label.get_style_context().add_class("workspace-count")
        count_label.set_halign(Gtk.Align.END)
        header.add(count_label)
        main_container.add(header)
        
        # Content area
        if workspace_clients:
            layout = Gtk.Layout()
            layout.set_size_request(self.content_width, self.content_height)
            self._position_windows(workspace_clients, layout)
            main_container.add(layout)
        else:
            empty_label = Label(label="Empty")
            empty_label.get_style_context().add_class("empty-workspace")
            empty_label.set_halign(Gtk.Align.CENTER)
            empty_label.set_valign(Gtk.Align.CENTER)
            empty_label.set_size_request(self.content_width, self.content_height)
            
            empty_layout = Gtk.Layout()
            empty_layout.set_size_request(self.content_width, self.content_height)
            empty_layout.put(empty_label, (self.content_width - 60) // 2, (self.content_height - 20) // 2)
            main_container.add(empty_layout)
        
        main_container.set_style(f"padding: {self.padding}px;")
        self.add(main_container)

    def _position_windows(self, workspace_clients: List[Dict], container: Gtk.Layout):
        monitor_width = self.monitor_info.get("width", 3440)
        monitor_height = self.monitor_info.get("height", 1440)
        monitor_x = self.monitor_info.get("x", 0)
        monitor_y = self.monitor_info.get("y", 0)
        
        # Calculate scaling to maintain aspect ratio
        monitor_aspect = monitor_width / monitor_height
        content_aspect = self.content_width / self.content_height
        
        if monitor_aspect > content_aspect:
            scale = self.content_width / monitor_width
            scaled_width = self.content_width
            scaled_height = int(monitor_height * scale)
            offset_x, offset_y = 0, (self.content_height - scaled_height) // 2
        else:
            scale = self.content_height / monitor_height
            scaled_width = int(monitor_width * scale)
            scaled_height = self.content_height
            offset_x, offset_y = (self.content_width - scaled_width) // 2, 0
        
        for client in workspace_clients:
            window_at = client.get("at", [0, 0])
            window_size = client.get("size", [200, 150])
            
            # Scale position and size
            relative_x = window_at[0] - monitor_x
            relative_y = window_at[1] - monitor_y
            scaled_x = max(offset_x, min(int(relative_x * scale) + offset_x, 
                                       offset_x + scaled_width - max(12, int(window_size[0] * scale))))
            scaled_y = max(offset_y, min(int(relative_y * scale) + offset_y,
                                       offset_y + scaled_height - max(8, int(window_size[1] * scale))))
            scaled_w = max(12, int(window_size[0] * scale))
            scaled_h = max(8, int(window_size[1] * scale))
            
            window_widget = DraggableWindow(client, scaled_w, scaled_h, self.overview)
            container.put(window_widget, scaled_x, scaled_y)

    def _update_style(self):
        ctx = self.get_style_context()
        for cls in ["workspace-active", "workspace-inactive", "workspace-drag-hover-active", "workspace-drag-hover-inactive"]:
            ctx.remove_class(cls)
        
        if self.is_active:
            ctx.add_class("workspace-active")
        else:
            ctx.add_class("workspace-inactive")

    def _on_drag_received(self, widget, context, x, y, data, info, time):
        window_address = data.get_data().decode()
        try:
            exec_shell_command(f"hyprctl dispatch movetoworkspacesilent {self.workspace_id},address:{window_address}")
            Gtk.drag_finish(context, True, False, time)
            GLib.timeout_add(100, self.overview.refresh)
        except Exception as e:
            print(f"Error moving window: {e}")
            Gtk.drag_finish(context, False, False, time)

    def _on_drag_motion(self, widget, context, x, y, time):
        ctx = self.get_style_context()
        ctx.remove_class("workspace-active")
        ctx.remove_class("workspace-inactive")
        
        if self.is_active:
            ctx.add_class("workspace-drag-hover-active")
        else:
            ctx.add_class("workspace-drag-hover-inactive")
            
        Gdk.drag_status(context, Gdk.DragAction.MOVE, time)
        return True

    def _on_drag_leave(self, widget, context, time):
        self._update_style()

    def _on_click(self, widget, event):
        if event.button == 1:
            try:
                exec_shell_command(f"hyprctl dispatch workspace {self.workspace_id}")
                self.overview.close()
            except Exception as e:
                print(f"Error switching workspace: {e}")
        return True

class Overview:
    def __init__(self):
        self._load_css()
        self.hyprland = HyprlandClient()
        self.class_to_icon = {}
        self.app = None
        
        # Get screen dimensions
        screen = Gdk.Screen.get_default()
        self.overview_width = int(screen.get_width() * (PERCENT / 100))
        self.overview_height = int(screen.get_height() * (PERCENT / 100))
        
        self._setup_ui()

    def _load_css(self):
        css_path = os.path.expanduser("~/.config/scripts/overview_style.css")
        if os.path.isfile(css_path):
            try:
                css_provider = Gtk.CssProvider()
                css_provider.load_from_path(css_path)
                screen = Gdk.Screen.get_default()
                Gtk.StyleContext.add_provider_for_screen(
                    screen, css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                )
            except GLib.Error as e:
                print(f"Warning: Failed to load CSS: {e}")

    def _setup_ui(self):
        self.main_container = Box(orientation="v", spacing=10)
        self.main_container.get_style_context().add_class("main-container")
        
        self.workspace_grid = Gtk.Grid()
        self.workspace_grid.set_column_spacing(8)
        self.workspace_grid.set_row_spacing(8)
        self.workspace_grid.set_column_homogeneous(True)
        self.workspace_grid.set_row_homogeneous(True)
        self.workspace_grid.set_halign(Gtk.Align.CENTER)
        self.workspace_grid.set_valign(Gtk.Align.CENTER)
        
        self.main_container.add(self.workspace_grid)
        
        self.window = Window(
            child=self.main_container,
            layer="overlay",
            anchor="",
            keyboard_mode="on-demand",
            margin="0px",
            on_destroy=lambda w, *_: w.application.quit()
        )
        
        self.window.set_default_size(self.overview_width, self.overview_height)
        self.window.add_keybinding("Escape", lambda w, *_: w.application.quit())

    def run(self):
        workspaces, clients, active_workspace, monitors = self.hyprland.get_data()
        
        # Add icons to clients
        self.class_to_icon = add_icons_to_clients(clients)
        
        # Prepare workspaces
        active_id = active_workspace.get("id", -1)
        monitor_info = monitors[0] if monitors else {"width": 3440, "height": 1440, "x": 0, "y": 0}
        
        workspace_ids = {ws.get("id", 0) for ws in workspaces}
        workspaces.extend({"id": i, "name": str(i), "windows": 0} 
                         for i in range(1, ROWS * COLS + 1) if i not in workspace_ids)
        workspaces.sort(key=lambda w: w.get("id", 0))
        
        # Calculate workspace dimensions
        monitor_aspect = monitor_info["width"] / monitor_info["height"]
        self.workspace_width, self.workspace_height = self._calculate_workspace_dimensions(monitor_aspect)
        self.monitor_info = monitor_info
        
        # Populate workspace grid
        self._populate_grid(workspaces[:COLS * ROWS], clients, active_id)
        
        # Run application
        self.app = Application("hyprland-overview", self.window)
        self.main_container.show_all()
        self.window.show_all()
        self.app.run()

    def _calculate_workspace_dimensions(self, monitor_aspect):
        available_width = self.overview_width - 50
        available_height = self.overview_height - 50
        
        grid_content_width = available_width - (COLS - 1) * 8
        grid_content_height = available_height - (ROWS - 1) * 8
        
        workspace_width_by_cols = grid_content_width // COLS
        workspace_height_by_aspect = int(workspace_width_by_cols / monitor_aspect)
        
        workspace_height_by_rows = grid_content_height // ROWS
        workspace_width_by_aspect = int(workspace_height_by_rows * monitor_aspect)
        
        if workspace_height_by_aspect <= grid_content_height // ROWS:
            return workspace_width_by_cols, workspace_height_by_aspect
        else:
            return max(150, workspace_width_by_aspect), max(int(150 / monitor_aspect), workspace_height_by_rows)

    def _populate_grid(self, workspaces, clients, active_id):
        for i, workspace in enumerate(workspaces):
            workspace_id = workspace.get("id", 0)
            is_active = workspace_id == active_id
            workspace_widget = WorkspaceDropZone(
                workspace, clients, is_active, self,
                self.workspace_width, self.workspace_height, self.monitor_info
            )
            
            row, col = divmod(i, COLS)
            self.workspace_grid.attach(workspace_widget, col, row, 1, 1)

    def refresh(self):
        workspaces, clients, active_workspace, _ = self.hyprland.get_data()
        
        # Reuse cached icon mapping
        for client in clients:
            cls = client.get("class")
            if cls and cls in self.class_to_icon:
                client["icon"] = self.class_to_icon[cls]
        
        # Clear and repopulate grid
        for child in self.workspace_grid.get_children():
            self.workspace_grid.remove(child)
        
        active_id = active_workspace.get("id", -1)
        workspace_ids = {ws.get("id", 0) for ws in workspaces}
        workspaces.extend({"id": i, "name": str(i), "windows": 0} 
                         for i in range(1, ROWS * COLS + 1) if i not in workspace_ids)
        workspaces.sort(key=lambda w: w.get("id", 0))
        
        self._populate_grid(workspaces[:COLS * ROWS], clients, active_id)
        self.workspace_grid.show_all()
        return False

    def close(self):
        if self.app:
            self.app.quit()

def main():
    overview = Overview()
    overview.run()

if __name__ == "__main__":
    main()
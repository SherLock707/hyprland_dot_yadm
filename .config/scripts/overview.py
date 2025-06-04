#!/usr/bin/env python3

import json
import cairo
import gi
import os
from typing import Dict, List

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")

from gi.repository import Gtk, Gdk, GLib, Gio, Rsvg
from fabric import Application
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.eventbox import EventBox
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.utils import exec_shell_command

TARGET = [Gtk.TargetEntry.new("text/plain", Gtk.TargetFlags.SAME_APP, 0)]

# -----------------ICON --------------------------------
DESKTOP_DIRS = [
    "/usr/share/applications",
    os.path.expanduser("~/.local/share/applications"),
]

def find_desktop_file(app_name):
    for base in DESKTOP_DIRS:
        for fname in os.listdir(base):
            if not fname.endswith(".desktop"):
                continue
            if app_name.lower() in fname.lower():
                return os.path.join(base, fname)
    return None

def get_icon_path_from_desktop_file(path, size=64):
    if not os.path.exists(path):
        print("Icon path does not exist")
        return None

    app_info = Gio.DesktopAppInfo.new_from_filename(path)
    icon = app_info.get_icon()

    if not icon:
        print("No Icon")
        return None

    theme = Gtk.IconTheme.get_default()

    if isinstance(icon, Gio.ThemedIcon):
        for name in icon.get_names():
            info = theme.lookup_icon(name, size, 0)
            # if info:
            return info.get_filename()
    elif isinstance(icon, Gio.FileIcon):
        return icon.get_file().get_path()

    print("No Icon-end")
    return None

def get_icon_for_app(app_name):
    desktop = find_desktop_file(app_name)
    if desktop:
        return get_icon_path_from_desktop_file(desktop)
    return None

def add_icons_to_windows(clients):
    # Step 1: Get unique classes
    unique_classes = {client.get("class") for client in clients if client.get("class")}

    # Step 2: Build map of class -> icon path
    class_to_icon = {cls: get_icon_for_app(cls) for cls in unique_classes}

    # Step 3: Assign icon paths back to clients
    # for client in clients:
    #     cls = client.get("class")
    #     if cls:
    #         client["icon"] = class_to_icon.get(cls, None)

    return class_to_icon


# ---------------------------------------------------------------------

def load_css():
    """Load CSS from external file"""
    css_provider = Gtk.CssProvider()
    script_dir = os.path.dirname(os.path.abspath(__file__))
    css_file = os.path.join(script_dir, "overview_style.css")
    
    try:
        css_provider.load_from_path(css_file)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
    except Exception as e:
        print(f"Warning: Could not load CSS file {css_file}: {e}")
        print("Falling back to inline styles")

def create_surface_from_widget(widget: Gtk.Widget) -> cairo.ImageSurface:
    alloc = widget.get_allocation()
    surface = cairo.ImageSurface(cairo.Format.ARGB32, alloc.width, alloc.height)
    cr = cairo.Context(surface)
    cr.set_source_rgba(0, 0, 0, 0)
    cr.rectangle(0, 0, alloc.width, alloc.height)
    cr.fill()
    widget.draw(cr)
    return surface

class HyprlandClient:
    @staticmethod
    def get_workspaces() -> List[Dict]:
        try:
            result = exec_shell_command("hyprctl workspaces -j")
            workspaces = json.loads(result) if result else []
            return [ws for ws in workspaces if ws.get("id", 0) > 0]
        except:
            return []
    
    @staticmethod
    def get_clients() -> List[Dict]:
        try:
            result = exec_shell_command("hyprctl clients -j")
            return json.loads(result) if result else []
        except:
            return []
    
    @staticmethod
    def get_active_workspace() -> Dict:
        try:
            result = exec_shell_command("hyprctl activeworkspace -j")
            return json.loads(result) if result else {}
        except:
            return {}
    
    @staticmethod
    def get_monitors() -> List[Dict]:
        try:
            result = exec_shell_command("hyprctl monitors -j")
            return json.loads(result) if result else []
        except:
            return []

class DraggableWindow2(EventBox):
    def __init__(self, client: Dict, window_width: int, window_height: int, overview_widget):
        super().__init__()
        self.client = client
        self.overview_widget = overview_widget
        self.window_address = client.get("address", "")
        self.is_dragging = False
        self.drag_started = False
        self.button_press_time = 0
        self.button_press_pos = (0, 0)
        self.drag_threshold = 5  # pixels
        
        self.set_size_request(window_width, window_height)
        
        window_content = Box(orientation="v", spacing=1)
        window_content.get_style_context().add_class("workspace-content")
        
        max_chars = max(5, window_width // 8)
        title_text = client.get("title", "")[:max_chars]
        if not title_text:
            title_text = client.get("class", "Unknown")[:max_chars]
            
        if window_height > 25:
            title_label = Label(
                label=title_text + ("..." if len(client.get("title", "")) > max_chars else "")
            )
            title_label.get_style_context().add_class("window-title")
            title_label.set_halign(Gtk.Align.CENTER)
            window_content.add(title_label)
        
        if window_height > 45:
            class_label = Label(
                label=client.get("class", "Unknown")[:max_chars]
            )
            class_label.get_style_context().add_class("window-class")
            class_label.set_halign(Gtk.Align.CENTER)
            window_content.add(class_label)
        
        self.add(window_content)
        self._update_style()
        
        self.drag_source_set(
            Gdk.ModifierType.BUTTON1_MASK,
            TARGET,
            Gdk.DragAction.MOVE
        )
        
        self.connect("drag-data-get", self._on_drag_data_get)
        self.connect("drag-begin", self._on_drag_begin)
        self.connect("drag-end", self._on_drag_end)
        self.connect("button-press-event", self._on_button_press)
        self.connect("button-release-event", self._on_button_release)
        self.connect("motion-notify-event", self._on_motion_notify)
        self.connect("enter-notify-event", self._on_enter)
        self.connect("leave-notify-event", self._on_leave)
        
        # Enable motion events
        self.set_events(self.get_events() | Gdk.EventMask.POINTER_MOTION_MASK)
        
    def _update_style(self):
        is_floating = self.client.get("floating", False)
        style_context = self.get_style_context()
        
        # Remove old classes
        style_context.remove_class("window-floating")
        style_context.remove_class("window-floating-hover")
        style_context.remove_class("window-tiled")
        style_context.remove_class("window-tiled-hover")
        
        if is_floating:
            style_context.add_class("window-floating")
        else:
            style_context.add_class("window-tiled")
        
    def _on_drag_data_get(self, widget, context, data, info, time):
        data.set_text(self.window_address, len(self.window_address))
        
    def _on_drag_begin(self, widget, context):
        self.is_dragging = True
        self.drag_started = True
        surface = create_surface_from_widget(self)
        Gtk.drag_set_icon_surface(context, surface)
        
    def _on_drag_end(self, widget, context):
        self.is_dragging = False
        # Reset drag_started after a short delay to handle the button release
        GLib.timeout_add(100, self._reset_drag_flag)
        
    def _reset_drag_flag(self):
        self.drag_started = False
        self.button_press_time = 0
        return False
        
    def _on_button_press(self, widget, event):
        if event.button == 1:  # Left click
            self.button_press_time = event.time
            self.button_press_pos = (event.x, event.y)
            # Don't handle the click immediately - wait to see if it's a drag
            return True
        elif event.button == 3:  # Right click - handle immediately
            try:
                workspace_id = self.client.get("workspace", {}).get("id", 1)
                exec_shell_command(f"hyprctl dispatch workspace {workspace_id}")
                self.overview_widget.close_overview()
            except Exception as e:
                print(f"Error switching workspace: {e}")
            return True
        return False
    
    def _on_motion_notify(self, widget, event):
        # If we have a button press but haven't started dragging yet,
        # check if we've moved enough to consider it a drag
        if (self.button_press_time > 0 and not self.drag_started and 
            event.state & Gdk.ModifierType.BUTTON1_MASK):
            
            dx = abs(event.x - self.button_press_pos[0])
            dy = abs(event.y - self.button_press_pos[1])
            
            if dx > self.drag_threshold or dy > self.drag_threshold:
                # This is a drag operation, let the drag system handle it
                # The drag will be initiated by GTK's drag system
                pass
        
        return False
        
    def _on_button_release(self, widget, event):
        if event.button == 1 and self.button_press_time > 0:
            # Check if this was a click (not a drag)
            time_diff = event.time - self.button_press_time
            dx = abs(event.x - self.button_press_pos[0])
            dy = abs(event.y - self.button_press_pos[1])
            
            # Consider it a click if:
            # 1. We didn't start a drag operation AND
            # 2. The mouse didn't move much AND
            # 3. It was a quick press/release
            if (not self.drag_started and 
                dx <= self.drag_threshold and dy <= self.drag_threshold and
                time_diff < 500):  # 500ms threshold for click
                
                try:
                    workspace_id = self.client.get("workspace", {}).get("id", 1)
                    exec_shell_command(f"hyprctl dispatch workspace {workspace_id}")
                    exec_shell_command(f"hyprctl dispatch focuswindow address:{self.window_address}")
                    self.overview_widget.close_overview()
                except Exception as e:
                    print(f"Error focusing window: {e}")
            
            # Reset button press tracking
            self.button_press_time = 0
        
        return True
    
    def _on_enter(self, widget, event):
        if self.is_dragging:
            return False
        
        is_floating = self.client.get("floating", False)
        style_context = self.get_style_context()
        
        # Remove old classes
        style_context.remove_class("window-floating")
        style_context.remove_class("window-tiled")
        
        if is_floating:
            style_context.add_class("window-floating-hover")
        else:
            style_context.add_class("window-tiled-hover")
        return False
    
    def _on_leave(self, widget, event):
        if self.is_dragging:
            return False
        self._update_style()
        return False

class DraggableWindow(EventBox):
    def __init__(self, client: Dict, window_width: int, window_height: int, overview_widget):
        super().__init__()
        self.client = client
        self.overview_widget = overview_widget
        self.window_address = client.get("address", "")
        self.is_dragging = False
        self.drag_started = False
        self.button_press_time = 0
        self.button_press_pos = (0, 0)
        self.drag_threshold = 5  # pixels

        self.set_size_request(window_width, window_height)

        window_content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=1)
        window_content.get_style_context().add_class("workspace-content")

        max_chars = max(5, window_width // 8)
        title_text = client.get("title", "")[:max_chars]
        if not title_text:
            title_text = client.get("class", "Unknown")[:max_chars]

        if window_height > 25:
            title_label = Gtk.Label(label=title_text + ("..." if len(client.get("title", "")) > max_chars else ""))
            title_label.get_style_context().add_class("window-title")
            title_label.set_halign(Gtk.Align.CENTER)
            window_content.add(title_label)

        if window_height > 45:
            class_label = Gtk.Label(label=client.get("class", "Unknown")[:max_chars])
            class_label.get_style_context().add_class("window-class")
            class_label.set_halign(Gtk.Align.CENTER)
            window_content.add(class_label)

        # Load SVG icon if path given
        self.svg_handle = None
        svg_path = client.get("icon")
        if svg_path:
            try:
                self.svg_handle = Rsvg.Handle.new_from_file(svg_path)
            except Exception as e:
                print(f"Error loading SVG icon '{svg_path}': {e}")

        # Add drawing area to render SVG icon centered
        if self.svg_handle:
            drawing_area = Gtk.DrawingArea()
            # Size roughly half the window size, adjust as needed
            icon_size = min(window_width, window_height) // 2
            drawing_area.set_size_request(icon_size, icon_size)
            drawing_area.connect("draw", self.on_draw_svg)
            window_content.add(drawing_area)

        self.add(window_content)
        self._update_style()

        self.drag_source_set(
            Gdk.ModifierType.BUTTON1_MASK,
            TARGET,
            Gdk.DragAction.MOVE,
        )

        self.connect("drag-data-get", self._on_drag_data_get)
        self.connect("drag-begin", self._on_drag_begin)
        self.connect("drag-end", self._on_drag_end)
        self.connect("button-press-event", self._on_button_press)
        self.connect("button-release-event", self._on_button_release)
        self.connect("motion-notify-event", self._on_motion_notify)
        self.connect("enter-notify-event", self._on_enter)
        self.connect("leave-notify-event", self._on_leave)

        # Enable motion events
        self.set_events(self.get_events() | Gdk.EventMask.POINTER_MOTION_MASK)

    def _update_style(self):
        is_floating = self.client.get("floating", False)
        style_context = self.get_style_context()

        style_context.remove_class("window-floating")
        style_context.remove_class("window-floating-hover")
        style_context.remove_class("window-tiled")
        style_context.remove_class("window-tiled-hover")

        if is_floating:
            style_context.add_class("window-floating")
        else:
            style_context.add_class("window-tiled")

    def _on_drag_data_get(self, widget, context, data, info, time):
        data.set_text(self.window_address, len(self.window_address))

    def _on_drag_begin(self, widget, context):
        self.is_dragging = True
        self.drag_started = True
        surface = create_surface_from_widget(self)
        Gtk.drag_set_icon_surface(context, surface)

    def _on_drag_end(self, widget, context):
        self.is_dragging = False
        GLib.timeout_add(100, self._reset_drag_flag)

    def _reset_drag_flag(self):
        self.drag_started = False
        self.button_press_time = 0
        return False

    def _on_button_press(self, widget, event):
        if event.button == 1:
            self.button_press_time = event.time
            self.button_press_pos = (event.x, event.y)
            return True
        elif event.button == 3:
            try:
                workspace_id = self.client.get("workspace", {}).get("id", 1)
                exec_shell_command(f"hyprctl dispatch workspace {workspace_id}")
                self.overview_widget.close_overview()
            except Exception as e:
                print(f"Error switching workspace: {e}")
            return True
        return False

    def _on_motion_notify(self, widget, event):
        if (
            self.button_press_time > 0
            and not self.drag_started
            and event.state & Gdk.ModifierType.BUTTON1_MASK
        ):
            dx = abs(event.x - self.button_press_pos[0])
            dy = abs(event.y - self.button_press_pos[1])

            if dx > self.drag_threshold or dy > self.drag_threshold:
                pass

        return False

    def _on_button_release(self, widget, event):
        if event.button == 1 and self.button_press_time > 0:
            time_diff = event.time - self.button_press_time
            dx = abs(event.x - self.button_press_pos[0])
            dy = abs(event.y - self.button_press_pos[1])

            if (
                not self.drag_started
                and dx <= self.drag_threshold
                and dy <= self.drag_threshold
                and time_diff < 500
            ):
                try:
                    workspace_id = self.client.get("workspace", {}).get("id", 1)
                    exec_shell_command(f"hyprctl dispatch workspace {workspace_id}")
                    exec_shell_command(f"hyprctl dispatch focuswindow address:{self.window_address}")
                    self.overview_widget.close_overview()
                except Exception as e:
                    print(f"Error focusing window: {e}")

            self.button_press_time = 0

        return True

    def _on_enter(self, widget, event):
        if self.is_dragging:
            return False

        is_floating = self.client.get("floating", False)
        style_context = self.get_style_context()

        style_context.remove_class("window-floating")
        style_context.remove_class("window-tiled")

        if is_floating:
            style_context.add_class("window-floating-hover")
        else:
            style_context.add_class("window-tiled-hover")
        return False

    def _on_leave(self, widget, event):
        if self.is_dragging:
            return False
        self._update_style()
        return False

    def on_draw_svg(self, widget, cr):
        if not self.svg_handle:
            return False

        width = widget.get_allocated_width()
        height = widget.get_allocated_height()

        # Clear background (optional)
        cr.set_source_rgba(0, 0, 0, 0)
        # cr.set_operator(cairo.OPERATOR_SOURCE)
        cr.paint()
        # cr.set_operator(cairo.OPERATOR_OVER)

        # SVG original dimensions
        dim = self.svg_handle.get_dimensions()
        svg_width = dim.width
        svg_height = dim.height

        # Calculate scale preserving aspect ratio
        scale_x = width / svg_width
        scale_y = height / svg_height
        scale = min(scale_x, scale_y)

        # Center SVG
        offset_x = (width - svg_width * scale) / 2
        offset_y = (height - svg_height * scale) / 2

        cr.translate(offset_x, offset_y)
        cr.scale(scale, scale)

        self.svg_handle.render_cairo(cr)

        return False

class WorkspaceDropZone(EventBox):
    def __init__(self, workspace: Dict, clients: List[Dict], is_active: bool, overview_widget, 
                 width: int, height: int, monitor_info: Dict):
        super().__init__()
        self.workspace = workspace
        self.workspace_id = workspace.get("id", 0)
        self.overview_widget = overview_widget
        self.monitor_info = monitor_info
        self.is_active = is_active
        
        # Calculate actual content area dimensions
        self.padding = 2
        self.header_height = 2
        self.content_width = width - (self.padding * 2)
        self.content_height = height - (self.padding * 2) - self.header_height
        
        self.set_size_request(width, height)
        
        self.drag_dest_set(
            Gtk.DestDefaults.ALL,
            TARGET,
            Gdk.DragAction.MOVE
        )
        self.connect("drag-data-received", self._on_drag_data_received)
        self.connect("drag-motion", self._on_drag_motion)
        self.connect("drag-leave", self._on_drag_leave)
        
        self._create_workspace_content(clients)
        self._update_style()
        
        self.connect("button-press-event", self._on_workspace_click)
        
    def _create_workspace_content(self, clients: List[Dict]):
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
        
        # Content area with proper scaling
        if workspace_clients:
            workspace_container = Gtk.Layout()
            workspace_container.set_size_request(self.content_width, self.content_height)
            
            self._position_windows(workspace_clients, workspace_container)
            main_container.add(workspace_container)
        else:
            empty_label = Label(label="Empty")
            empty_label.get_style_context().add_class("empty-workspace")
            empty_label.set_halign(Gtk.Align.CENTER)
            empty_label.set_valign(Gtk.Align.CENTER)
            empty_label.set_size_request(self.content_width, self.content_height)
            
            empty_container = Gtk.Layout()
            empty_container.set_size_request(self.content_width, self.content_height)
            empty_container.put(empty_label, (self.content_width - 60) // 2, (self.content_height - 20) // 2)
            
            main_container.add(empty_container)
        
        # Add padding with CSS class instead of inline style
        main_container.set_style(f"padding: {self.padding}px;")
        self.add(main_container)
    
    def _position_windows(self, workspace_clients: List[Dict], container: Gtk.Layout):
        # Get monitor dimensions (ignore waybar, use full monitor as reference)
        monitor_width = self.monitor_info.get("width", 3440)
        monitor_height = self.monitor_info.get("height", 1440)
        monitor_x = self.monitor_info.get("x", 0)
        monitor_y = self.monitor_info.get("y", 0)
        
        # Calculate scaling factor to fit monitor aspect ratio in content area
        # This ensures the workspace maintains the same aspect ratio as the monitor
        monitor_aspect = monitor_width / monitor_height
        content_aspect = self.content_width / self.content_height
        
        if monitor_aspect > content_aspect:
            # Monitor is wider - fit by width
            scale = self.content_width / monitor_width
            scaled_monitor_width = self.content_width
            scaled_monitor_height = int(monitor_height * scale)
            # Center vertically
            offset_x = 0
            offset_y = (self.content_height - scaled_monitor_height) // 2
        else:
            # Monitor is taller - fit by height
            scale = self.content_height / monitor_height
            scaled_monitor_width = int(monitor_width * scale)
            scaled_monitor_height = self.content_height
            # Center horizontally
            offset_x = (self.content_width - scaled_monitor_width) // 2
            offset_y = 0
        
        for client in workspace_clients:
            window_at = client.get("at", [0, 0])
            window_size = client.get("size", [200, 150])
            
            # Calculate position relative to monitor origin
            relative_x = window_at[0] - monitor_x
            relative_y = window_at[1] - monitor_y
            
            # Scale the position and size
            scaled_x = int(relative_x * scale) + offset_x
            scaled_y = int(relative_y * scale) + offset_y
            scaled_width = max(12, int(window_size[0] * scale))
            scaled_height = max(8, int(window_size[1] * scale))
            
            # Ensure windows stay within the scaled monitor bounds
            max_x = offset_x + scaled_monitor_width - scaled_width
            max_y = offset_y + scaled_monitor_height - scaled_height
            
            scaled_x = max(offset_x, min(scaled_x, max_x))
            scaled_y = max(offset_y, min(scaled_y, max_y))
                        
            window_widget = DraggableWindow(client, scaled_width, scaled_height, self.overview_widget)
            container.put(window_widget, scaled_x, scaled_y)
    
    def _update_style(self):
        style_context = self.get_style_context()
        
        # Remove all workspace classes
        style_context.remove_class("workspace-active")
        style_context.remove_class("workspace-inactive")
        style_context.remove_class("workspace-drag-hover-active")
        style_context.remove_class("workspace-drag-hover-inactive")
        
        if self.is_active:
            style_context.add_class("workspace-active")
        else:
            style_context.add_class("workspace-inactive")
    
    def _on_drag_data_received(self, widget, context, x, y, data, info, time):
        window_address = data.get_data().decode()
        try:
            exec_shell_command(f"hyprctl dispatch movetoworkspacesilent {self.workspace_id},address:{window_address}")
            Gtk.drag_finish(context, True, False, time)
            # Refresh the overview after successful drop
            GLib.timeout_add(100, self.overview_widget.refresh_overview)
        except Exception as e:
            print(f"Error moving window: {e}")
            Gtk.drag_finish(context, False, False, time)
        
    def _on_drag_motion(self, widget, context, x, y, time):
        style_context = self.get_style_context()
        
        # Remove current classes
        style_context.remove_class("workspace-active")
        style_context.remove_class("workspace-inactive")
        
        if self.is_active:
            style_context.add_class("workspace-drag-hover-active")
        else:
            style_context.add_class("workspace-drag-hover-inactive")
            
        Gdk.drag_status(context, Gdk.DragAction.MOVE, time)
        return True
        
    def _on_drag_leave(self, widget, context, time):
        self._update_style()
        
    def _on_workspace_click(self, widget, event):
        if event.button == 1:
            try:
                exec_shell_command(f"hyprctl dispatch workspace {self.workspace_id}")
                self.overview_widget.close_overview()
            except Exception as e:
                print(f"Error switching workspace: {e}")
        return True

def main(percent=70):
    # Load CSS styles
    load_css()
    
    workspaces = HyprlandClient.get_workspaces()
    clients = HyprlandClient.get_clients()
    active_workspace = HyprlandClient.get_active_workspace()
    monitors = HyprlandClient.get_monitors()

    class_to_icon = add_icons_to_windows(clients)

    # Add 'icon' svg path to dict
    for client in clients:
        cls = client.get("class")
        if cls:
            client["icon"] = class_to_icon.get(cls, None)

    active_id = active_workspace.get("id", -1)
    monitor_info = monitors[0] if monitors else {"width": 3440, "height": 1440, "x": 0, "y": 0}
    
    # Get monitor dimensions
    monitor_width = monitor_info.get("width", 3440)
    monitor_height = monitor_info.get("height", 1440)
    monitor_aspect = monitor_width / monitor_height
    
    workspace_ids = set([ws.get("id", 0) for ws in workspaces])
    for i in range(1, 11):
        if i not in workspace_ids:
            workspaces.append({"id": i, "name": str(i), "windows": 0})
    
    workspaces.sort(key=lambda w: w.get("id", 0))
    
    screen = Gdk.Screen.get_default()
    screen_width = screen.get_width()
    screen_height = screen.get_height()
    
    overview_width = int(screen_width * (percent / 100))
    overview_height = int(screen_height * (percent / 100))
    
    cols, rows = 5, 2
    
    main_container = Box(orientation="v", spacing=10)
    main_container.get_style_context().add_class("main-container")
    
    workspace_grid = Gtk.Grid()
    workspace_grid.set_column_spacing(8)
    workspace_grid.set_row_spacing(8)
    workspace_grid.set_column_homogeneous(True)
    workspace_grid.set_row_homogeneous(True)
    workspace_grid.set_halign(Gtk.Align.CENTER)
    workspace_grid.set_valign(Gtk.Align.CENTER)
    
    # Calculate workspace dimensions
    available_width = overview_width - 50  # Account for main container padding
    available_height = overview_height - 50
    
    # Account for grid spacing
    total_h_spacing = (cols - 1) * 8
    total_v_spacing = (rows - 1) * 8
    
    grid_content_width = available_width - total_h_spacing
    grid_content_height = available_height - total_v_spacing
    
    # Calculate individual workspace size maintaining monitor aspect ratio
    workspace_width_by_cols = grid_content_width // cols
    workspace_height_by_aspect = int(workspace_width_by_cols / monitor_aspect)
    
    workspace_height_by_rows = grid_content_height // rows
    workspace_width_by_aspect = int(workspace_height_by_rows * monitor_aspect)
    
    # Choose the constraint that fits
    if workspace_height_by_aspect <= grid_content_height // rows:
        workspace_width = workspace_width_by_cols
        workspace_height = workspace_height_by_aspect
    else:
        workspace_width = workspace_width_by_aspect
        workspace_height = workspace_height_by_rows
    
    # Ensure minimum size
    min_width = 150
    min_height = int(min_width / monitor_aspect)
    
    if workspace_width < min_width:
        workspace_width = min_width
        workspace_height = min_height
    
    class OverviewApp:
        def __init__(self, app=None, main_container=None, workspace_grid=None):
            self.app = app
            self.main_container = main_container
            self.workspace_grid = workspace_grid
            self.workspace_width = workspace_width
            self.workspace_height = workspace_height
            self.monitor_info = monitor_info
            self.cols = cols
            self.rows = rows
        
        def close_overview(self):
            if self.app:
                self.app.quit()
                
        def refresh_overview(self):
            # Get updated data
            workspaces = HyprlandClient.get_workspaces()
            clients = HyprlandClient.get_clients()
            active_workspace = HyprlandClient.get_active_workspace()
            active_id = active_workspace.get("id", -1)

            for client in clients:
                cls = client.get("class")
                if cls:
                    client["icon"] = class_to_icon.get(cls, None)
            
            # Add empty workspaces
            workspace_ids = set([ws.get("id", 0) for ws in workspaces])
            for i in range(1, 11):
                if i not in workspace_ids:
                    workspaces.append({"id": i, "name": str(i), "windows": 0})
            
            workspaces.sort(key=lambda w: w.get("id", 0))
            
            # Clear existing workspace widgets
            for child in self.workspace_grid.get_children():
                self.workspace_grid.remove(child)
            
            # Recreate workspace widgets with updated data
            for i, workspace in enumerate(workspaces):
                if i >= self.cols * self.rows:
                    break
                    
                workspace_id = workspace.get("id", 0)
                is_active = workspace_id == active_id
                workspace_widget = WorkspaceDropZone(
                    workspace, clients, is_active, self,
                    self.workspace_width, self.workspace_height, self.monitor_info
                )
                
                row = i // self.cols
                col = i % self.cols
                self.workspace_grid.attach(workspace_widget, col, row, 1, 1)
            
            self.workspace_grid.show_all()
            return False  # Don't repeat the timeout
    
    overview_app = OverviewApp(None, main_container, workspace_grid)
    
    for i, workspace in enumerate(workspaces):
        if i >= cols * rows:
            break
            
        workspace_id = workspace.get("id", 0)
        is_active = workspace_id == active_id
        workspace_widget = WorkspaceDropZone(
            workspace, clients, is_active, overview_app,
            workspace_width, workspace_height, monitor_info
        )
        
        row = i // cols
        col = i % cols
        workspace_grid.attach(workspace_widget, col, row, 1, 1)
    
    main_container.add(workspace_grid)
    
    window = Window(
        child=main_container,
        layer="overlay",
        anchor="",
        keyboard_mode="on-demand",
        margin="0px",
        on_destroy=lambda w, *_: w.application.quit()
    )
    
    window.set_default_size(overview_width, overview_height)
    window.add_keybinding("Escape", lambda w, *_: w.application.quit())
    window.add_keybinding("F5", lambda w, *_: main(percent))
    
    app = Application("hyprland-overview", window)
    overview_app.app = app
    
    main_container.show_all()
    window.show_all()
    app.run()

if __name__ == "__main__":
    import sys
    
    percent = 78
    if len(sys.argv) > 1:
        try:
            percent = int(sys.argv[1])
        except ValueError:
            print("Invalid percentage, using default 70%")
    
    try:
        main(percent)
    except Exception as e:
        import traceback
        print(f"Error: {e}")
        print(traceback.format_exc())
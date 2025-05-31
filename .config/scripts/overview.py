#!/usr/bin/env python3

"""
Enhanced Hyprland Overview Widget with Proper Window Scaling to Fill Workspace
"""

import json
import gi
from typing import Dict, List

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")

from gi.repository import Gtk, Gdk, GLib
from fabric import Application
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.eventbox import EventBox
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.utils import exec_shell_command


class HyprlandClient:
    """Client for interacting with Hyprland IPC"""
    
    @staticmethod
    def get_workspaces() -> List[Dict]:
        """Get all workspaces from Hyprland (excluding special workspaces)"""
        try:
            result = exec_shell_command("hyprctl workspaces -j")
            workspaces = json.loads(result) if result else []
            # Filter out special workspaces (negative IDs)
            return [ws for ws in workspaces if ws.get("id", 0) > 0]
        except Exception as e:
            print(f"Error getting workspaces: {e}")
            return []
    
    @staticmethod
    def get_clients() -> List[Dict]:
        """Get all clients (windows) from Hyprland"""
        try:
            result = exec_shell_command("hyprctl clients -j")
            return json.loads(result) if result else []
        except Exception as e:
            print(f"Error getting clients: {e}")
            return []
    
    @staticmethod
    def get_active_workspace() -> Dict:
        """Get the currently active workspace"""
        try:
            result = exec_shell_command("hyprctl activeworkspace -j")
            return json.loads(result) if result else {}
        except Exception as e:
            print(f"Error getting active workspace: {e}")
            return {}
    
    @staticmethod
    def get_monitors() -> List[Dict]:
        """Get monitor information"""
        try:
            result = exec_shell_command("hyprctl monitors -j")
            return json.loads(result) if result else []
        except Exception as e:
            print(f"Error getting monitors: {e}")
            return []


class WindowWidget(EventBox):
    """Widget representing a single window within a workspace"""
    
    def __init__(self, client: Dict, window_width: int, window_height: int, overview_widget):
        super().__init__()
        self.client = client
        self.overview_widget = overview_widget
        
        # Get window properties
        self.window_class = client.get("class", "Unknown")
        self.window_title = client.get("title", "")
        self.window_address = client.get("address", "")
        
        # Use the calculated window size directly
        self.set_size_request(window_width, window_height)
        
        # Create window content
        window_content = Box(orientation="v", spacing=1)
        
        # Window title (truncated based on size)
        max_chars = max(5, window_width // 8)  # Approximate character width
        title_text = self.window_title[:max_chars] + "..." if len(self.window_title) > max_chars else self.window_title
        if not title_text:
            title_text = self.window_class[:max_chars]
            
        # Only show title if window is large enough
        if window_height > 35:
            title_label = Label(
                label=title_text,
                style="color: white; font-size: 10px; font-weight: bold;"
            )
            title_label.set_halign(Gtk.Align.CENTER)
            window_content.add(title_label)
        
        # Show class if there's enough space
        if window_height > 55:
            class_label = Label(
                label=self.window_class[:max_chars],
                style="color: rgba(255, 255, 255, 0.7); font-size: 8px;"
            )
            class_label.set_halign(Gtk.Align.CENTER)
            window_content.add(class_label)
        
        self.add(window_content)
        
        # Style based on window state
        if client.get("floating", False):
            # Floating windows get a different style
            border_color = "rgba(255, 200, 100, 0.8)"
            bg_color = "rgba(255, 200, 100, 0.15)"
        else:
            # Tiled windows
            border_color = "rgba(255, 255, 255, 0.4)"
            bg_color = "rgba(255, 255, 255, 0.1)"
        
        self.set_style(
            f"background: {bg_color}; "
            f"border: 1px solid {border_color}; "
            "border-radius: 3px; "
            "padding: 2px;"
        )
        
        # Connect events
        self.connect("button-press-event", self.on_button_press)
        self.connect("enter-notify-event", self.on_enter)
        self.connect("leave-notify-event", self.on_leave)
        
    def on_button_press(self, widget, event):
        """Handle window click - focus the window"""
        if event.button == 1:
            print(f"Focusing window: {self.window_class}")
            try:
                exec_shell_command(f"hyprctl dispatch focuswindow address:{self.window_address}")
                self.overview_widget.close_overview()
            except Exception as e:
                print(f"Error focusing window: {e}")
        return True
    
    def on_enter(self, widget, event):
        """Highlight on hover"""
        if self.client.get("floating", False):
            self.set_style(
                "background: rgba(255, 200, 100, 0.25); "
                "border: 1px solid rgba(255, 200, 100, 1); "
                "border-radius: 3px; "
                "padding: 2px;"
            )
        else:
            self.set_style(
                "background: rgba(255, 255, 255, 0.2); "
                "border: 1px solid rgba(255, 255, 255, 0.6); "
                "border-radius: 3px; "
                "padding: 2px;"
            )
        return False
    
    def on_leave(self, widget, event):
        """Remove highlight"""
        if self.client.get("floating", False):
            self.set_style(
                "background: rgba(255, 200, 100, 0.15); "
                "border: 1px solid rgba(255, 200, 100, 0.8); "
                "border-radius: 3px; "
                "padding: 2px;"
            )
        else:
            self.set_style(
                "background: rgba(255, 255, 255, 0.1); "
                "border: 1px solid rgba(255, 255, 255, 0.4); "
                "border-radius: 3px; "
                "padding: 2px;"
            )
        return False


class WorkspaceWidget(EventBox):
    """Enhanced workspace widget with proper window scaling to fill workspace"""
    
    def __init__(self, workspace: Dict, clients: List[Dict], is_active: bool, overview_widget, width: int, height: int):
        super().__init__()
        self.workspace = workspace
        self.workspace_id = workspace.get("id", 0)
        self.overview_widget = overview_widget
        
        # Use provided dimensions
        self.set_size_request(width, height)
        
        # Create main container
        main_container = Box(orientation="v", spacing=4)
        
        # Workspace header (smaller to save space)
        header = Box(orientation="h", spacing=8)
        
        # Workspace number/name
        ws_name = workspace.get("name", str(self.workspace_id))
        header_label = Label(
            label=f"WS {ws_name}",
            style="color: white; font-size: 11px; font-weight: bold;"
        )
        header_label.set_halign(Gtk.Align.START)
        header.add(header_label)
        
        # Window count
        workspace_clients = [c for c in clients if c.get("workspace", {}).get("id") == self.workspace_id]
        count_label = Label(
            label=f"({len(workspace_clients)})",
            style="color: rgba(255, 255, 255, 0.7); font-size: 9px;"
        )
        count_label.set_halign(Gtk.Align.END)
        header.add(count_label)
        
        main_container.add(header)
        
        # Create workspace area with proper scaling
        workspace_area_height = height - 35  # Account for header
        workspace_area_width = width - 20   # Account for padding
        
        if workspace_clients:
            # Create a fixed container for accurate positioning
            workspace_container = Gtk.Fixed()
            workspace_container.set_size_request(workspace_area_width, workspace_area_height)
            
            # Get monitor information to calculate workspace bounds
            monitors = HyprlandClient.get_monitors()
            monitor_info = None
            
            # Find the monitor for this workspace (simplified - assumes single monitor)
            if monitors:
                monitor_info = monitors[0]  # Use first monitor for now
            
            if monitor_info:
                monitor_width = monitor_info.get("width", 1920)
                monitor_height = monitor_info.get("height", 1080)
            else:
                # Fallback values
                monitor_width = 1920
                monitor_height = 1080
            
            # Calculate scale factors to fit workspace area
            scale_x = workspace_area_width / monitor_width
            scale_y = workspace_area_height / monitor_height
            
            print(f"Debug: Workspace {self.workspace_id} - Monitor: {monitor_width}x{monitor_height}")
            print(f"Debug: Workspace area: {workspace_area_width}x{workspace_area_height}")
            print(f"Debug: Scale factors: {scale_x}, {scale_y}")
            
            # Calculate the bounds of all windows to determine how to scale them
            if workspace_clients:
                min_x = min(client.get("at", [0, 0])[0] for client in workspace_clients)
                max_x = max(client.get("at", [0, 0])[0] + client.get("size", [200, 150])[0] for client in workspace_clients)
                min_y = min(client.get("at", [0, 0])[1] for client in workspace_clients)
                max_y = max(client.get("at", [0, 0])[1] + client.get("size", [200, 150])[1] for client in workspace_clients)
                
                # Calculate the actual used area
                used_width = max_x - min_x
                used_height = max_y - min_y
                
                # If used area is smaller than monitor, scale to fit the used area instead
                if used_width < monitor_width and used_height < monitor_height:
                    scale_x = workspace_area_width / max(used_width, 200)  # Minimum width
                    scale_y = workspace_area_height / max(used_height, 150)  # Minimum height
                    
                    print(f"Debug: Used area: {used_width}x{used_height}")
                    print(f"Debug: Adjusted scale factors: {scale_x}, {scale_y}")
                
                # Use uniform scaling but make it larger to fill more space
                base_scale = min(scale_x, scale_y)
                # Boost the scale to make windows more prominent - fill more of the workspace
                display_scale = base_scale * 2.0  # Make windows much larger
                
                print(f"Debug: Base scale: {base_scale}, Display scale: {display_scale}")
                
                # Position each window with proper scaling
                for client in workspace_clients:
                    # Get window position and size
                    window_at = client.get("at", [0, 0])
                    window_size = client.get("size", [200, 150])
                    
                    # Calculate scaled position (relative to min_x, min_y if we're scaling to used area)
                    if used_width < monitor_width and used_height < monitor_height:
                        relative_x = window_at[0] - min_x
                        relative_y = window_at[1] - min_y
                        scaled_x = int(relative_x * display_scale)
                        scaled_y = int(relative_y * display_scale)
                    else:
                        scaled_x = int(window_at[0] * display_scale)
                        scaled_y = int(window_at[1] * display_scale)
                    
                    # Calculate scaled window size - make them fill more space
                    base_window_width = max(60, int(window_size[0] * display_scale))
                    base_window_height = max(40, int(window_size[1] * display_scale))
                    
                    # Ensure windows are reasonably sized - boost small windows
                    min_window_width = workspace_area_width // 4  # At least 1/4 of workspace width
                    min_window_height = workspace_area_height // 4  # At least 1/4 of workspace height
                    
                    scaled_width = max(base_window_width, min_window_width)
                    scaled_height = max(base_window_height, min_window_height)
                    
                    # But don't make them larger than the workspace
                    scaled_width = min(scaled_width, workspace_area_width - 10)
                    scaled_height = min(scaled_height, workspace_area_height - 10)
                    
                    # Ensure positions are within bounds, accounting for window size
                    scaled_x = max(0, min(scaled_x, workspace_area_width - scaled_width))
                    scaled_y = max(0, min(scaled_y, workspace_area_height - scaled_height))
                    
                    print(f"Debug: Window {client.get('class', 'Unknown')}")
                    print(f"  Original: pos({window_at[0]}, {window_at[1]}) size({window_size[0]}x{window_size[1]})")
                    print(f"  Scaled: pos({scaled_x}, {scaled_y}) size({scaled_width}x{scaled_height})")
                    
                    # Create window widget with calculated size
                    window_widget = WindowWidget(client, scaled_width, scaled_height, overview_widget)
                    
                    # Position the window widget
                    workspace_container.put(window_widget, scaled_x, scaled_y)
            
            # Wrap in a frame to show workspace bounds
            frame = Gtk.Frame()
            frame.set_shadow_type(Gtk.ShadowType.IN)
            frame.add(workspace_container)
            frame.set_size_request(workspace_area_width, workspace_area_height)
            
            main_container.add(frame)
            
        else:
            # Empty workspace indicator
            empty_label = Label(
                label="Empty",
                style="color: rgba(255, 255, 255, 0.5); font-size: 10px; font-style: italic;"
            )
            empty_label.set_halign(Gtk.Align.CENTER)
            empty_label.set_valign(Gtk.Align.CENTER)
            empty_label.set_size_request(workspace_area_width, workspace_area_height)
            main_container.add(empty_label)
        
        self.add(main_container)
        
        # Style based on active state
        if is_active:
            border_style = "border: 2px solid rgba(100, 150, 255, 1);"
            bg_style = "background: rgba(100, 150, 255, 0.2);"
        else:
            border_style = "border: 1px solid rgba(255, 255, 255, 0.3);"
            bg_style = "background: rgba(255, 255, 255, 0.05);"
        
        self.set_style(f"{bg_style} {border_style} border-radius: 8px; margin: 8px; padding: 8px;")
        
        # Connect hover events
        self.connect("enter-notify-event", self.on_enter)
        self.connect("leave-notify-event", self.on_leave)
        
    def on_enter(self, widget, event):
        """Highlight on hover"""
        active_workspace = HyprlandClient.get_active_workspace()
        is_active = self.workspace_id == active_workspace.get("id", -1)
        
        if is_active:
            self.set_style(
                "background: rgba(100, 150, 255, 0.3); "
                "border: 2px solid rgba(100, 150, 255, 1); "
                "border-radius: 8px; margin: 8px; padding: 8px;"
            )
        else:
            self.set_style(
                "background: rgba(255, 255, 255, 0.1); "
                "border: 1px solid rgba(255, 255, 255, 0.5); "
                "border-radius: 8px; margin: 8px; padding: 8px;"
            )
        return False
    
    def on_leave(self, widget, event):
        """Remove highlight"""
        active_workspace = HyprlandClient.get_active_workspace()
        is_active = self.workspace_id == active_workspace.get("id", -1)
        
        if is_active:
            self.set_style(
                "background: rgba(100, 150, 255, 0.2); "
                "border: 2px solid rgba(100, 150, 255, 1); "
                "border-radius: 8px; margin: 8px; padding: 8px;"
            )
        else:
            self.set_style(
                "background: rgba(255, 255, 255, 0.05); "
                "border: 1px solid rgba(255, 255, 255, 0.3); "
                "border-radius: 8px; margin: 8px; padding: 8px;"
            )
        return False


def main(percent=60):
    """Enhanced main function with proper window scaling"""
    
    print("Debug: Starting Enhanced Hyprland Overview with Proper Window Scaling")
    
    # Get data from Hyprland
    workspaces = HyprlandClient.get_workspaces()
    clients = HyprlandClient.get_clients()
    active_workspace = HyprlandClient.get_active_workspace()
    monitors = HyprlandClient.get_monitors()
    
    active_id = active_workspace.get("id", -1)
    
    print(f"Debug: Found {len(workspaces)} workspaces, {len(clients)} windows")
    print(f"Debug: Active workspace: {active_id}")
    
    # Create a comprehensive list of workspaces (including empty ones up to 10)
    workspace_ids = set([ws.get("id", 0) for ws in workspaces])
    for i in range(1, 11):
        if i not in workspace_ids:
            workspaces.append({"id": i, "name": str(i), "windows": 0})
    
    # Sort workspaces by ID
    workspaces.sort(key=lambda w: w.get("id", 0))
    
    # Create main container with configurable size
    screen = Gdk.Screen.get_default()
    screen_width = screen.get_width()
    screen_height = screen.get_height()
    
    # Use configurable percentage of screen width and height
    overview_width = int(screen_width * (percent / 100))
    overview_height = int(screen_height * (percent / 100))
    
    print(f"Debug: Screen size: {screen_width}x{screen_height}")
    print(f"Debug: Calculated overview size: {overview_width}x{overview_height}")
    
    # Create main container
    main_container = Box(
        orientation="v",
        spacing=15,
        style="padding: 20px; background-color: rgba(30, 30, 46, 0.95); border-radius: 12px;"
    )
    
    # Create workspace grid
    workspace_grid = Gtk.FlowBox()
    workspace_grid.set_max_children_per_line(5)
    workspace_grid.set_column_spacing(10)
    workspace_grid.set_row_spacing(10)
    workspace_grid.set_homogeneous(True)
    workspace_grid.set_selection_mode(Gtk.SelectionMode.NONE)
    
    # Calculate workspace size
    available_width = overview_width - 60
    available_height = overview_height - 60
    
    workspace_width = (available_width - 20) // 3
    workspace_height = (available_height - 30) // 4
    
    print(f"Debug: Workspace size: {workspace_width}x{workspace_height}")
    
    class OverviewApp:
        def __init__(self, app=None):
            self.app = app
        
        def close_overview(self):
            if self.app:
                self.app.quit()
    
    overview_app = OverviewApp()
    
    # Add workspace widgets
    for workspace in workspaces:
        workspace_id = workspace.get("id", 0)
        is_active = workspace_id == active_id
        workspace_widget = WorkspaceWidget(workspace, clients, is_active, overview_app, workspace_width, workspace_height)
        workspace_grid.add(workspace_widget)
    
    main_container.add(workspace_grid)
    
    # Create centered window
    window = Window(
        child=main_container,
        layer="overlay",
        anchor="",
        keyboard_mode="on-demand",
        margin="0px",
        on_destroy=lambda w, *_: w.application.quit()
    )
    
    # Set window size
    window.set_default_size(overview_width, overview_height)
    window.set_size_request(overview_width, overview_height)
    main_container.set_size_request(overview_width, overview_height)
    workspace_grid.set_size_request(overview_width - 40, overview_height - 40)
    
    def on_window_realize(widget):
        try:
            if hasattr(widget, 'resize'):
                widget.resize(overview_width, overview_height)
            print(f"Debug: Window realized with target size {overview_width}x{overview_height}")
        except Exception as e:
            print(f"Debug: Could not resize window: {e}")
    
    window.connect("realize", on_window_realize)
    
    # Add keybindings
    window.add_keybinding("Escape", lambda w, *_: w.application.quit())
    window.add_keybinding("F5", lambda w, *_: main(width_percent, height_percent))
    
    # Create application
    app = Application("hyprland-overview", window)
    overview_app.app = app
    
    print("Debug: Application created, showing window")
    
    # Show everything
    main_container.show_all()
    window.show_all()
    
    print("Debug: About to run application")
    
    # Run
    app.run()


if __name__ == "__main__":
    import sys
    
    # Allow configurable width and height via command line arguments
    percent = 50
    
    if len(sys.argv) > 1:
        try:
            percent = int(sys.argv[1])
        except ValueError:
            print("Invalid width percentage, using default 70%")
    
    if len(sys.argv) > 2:
        try:
            percent = int(sys.argv[2])
        except ValueError:
            print("Invalid height percentage, using default 60%")
    
    print(f"Debug: Starting with dimensions {percent}% x {percent}%")
    
    try:
        main(percent)
    except Exception as e:
        import traceback
        print(f"Error: {e}")
        print(traceback.format_exc())
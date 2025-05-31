#!/usr/bin/env python3

"""
Enhanced Hyprland Overview Widget with Window Thumbnails
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
    
    def __init__(self, client: Dict, workspace_scale: float, overview_widget):
        super().__init__()
        self.client = client
        self.overview_widget = overview_widget
        
        # Get window properties
        self.window_class = client.get("class", "Unknown")
        self.window_title = client.get("title", "")
        self.window_address = client.get("address", "")
        
        # Scale window size relative to workspace - smaller to fit better
        window_width = max(50, int(client.get("size", [200, 150])[0] * workspace_scale))
        window_height = max(35, int(client.get("size", [200, 150])[1] * workspace_scale))
        
        self.set_size_request(window_width, window_height)
        
        # Create window content
        window_content = Box(orientation="v", spacing=2)
        
        # Window title (truncated)
        title_text = self.window_title[:20] + "..." if len(self.window_title) > 20 else self.window_title
        if not title_text:
            title_text = self.window_class
            
        title_label = Label(
            label=title_text,
            style="color: white; font-size: 10px; font-weight: bold;"
        )
        title_label.set_halign(Gtk.Align.CENTER)
        
        # Window class label
        class_label = Label(
            label=self.window_class,
            style="color: rgba(255, 255, 255, 0.7); font-size: 8px;"
        )
        class_label.set_halign(Gtk.Align.CENTER)
        
        window_content.add(title_label)
        window_content.add(class_label)
        
        self.add(window_content)
        
        # Style the window
        self.set_style(
            "background: rgba(255, 255, 255, 0.1); "
            "border: 1px solid rgba(255, 255, 255, 0.3); "
            "border-radius: 4px; "
            "margin: 2px; "
            "padding: 4px;"
        )
        
        # Connect click event
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
        self.set_style(
            "background: rgba(255, 255, 255, 0.2); "
            "border: 1px solid rgba(255, 255, 255, 0.5); "
            "border-radius: 4px; "
            "margin: 2px; "
            "padding: 4px;"
        )
        return False
    
    def on_leave(self, widget, event):
        """Remove highlight"""
        self.set_style(
            "background: rgba(255, 255, 255, 0.1); "
            "border: 1px solid rgba(255, 255, 255, 0.3); "
            "border-radius: 4px; "
            "margin: 2px; "
            "padding: 4px;"
        )
        return False


class WorkspaceWidget(EventBox):
    """Enhanced workspace widget showing windows"""
    
    def __init__(self, workspace: Dict, clients: List[Dict], is_active: bool, overview_widget, width: int, height: int):
        super().__init__()
        self.workspace = workspace
        self.workspace_id = workspace.get("id", 0)
        self.overview_widget = overview_widget
        
        # Use provided dimensions
        self.set_size_request(width, height)
        
        # Create main container
        main_container = Box(orientation="v", spacing=4)
        
        # Workspace header
        header = Box(orientation="h", spacing=8)
        
        # Workspace number/name
        ws_name = workspace.get("name", str(self.workspace_id))
        header_label = Label(
            label=f"Workspace {ws_name}",
            style="color: white; font-size: 12px; font-weight: bold;"
        )
        header_label.set_halign(Gtk.Align.START)
        header.add(header_label)
        
        # Window count
        workspace_clients = [c for c in clients if c.get("workspace", {}).get("id") == self.workspace_id]
        count_label = Label(
            label=f"({len(workspace_clients)} windows)",
            style="color: rgba(255, 255, 255, 0.7); font-size: 10px;"
        )
        count_label.set_halign(Gtk.Align.END)
        header.add(count_label)
        
        main_container.add(header)
        
        # Windows container - no scrolling, fixed size
        windows_container = Gtk.FlowBox()
        windows_container.set_max_children_per_line(3)
        windows_container.set_column_spacing(4)
        windows_container.set_row_spacing(4)
        windows_container.set_homogeneous(False)
        windows_container.set_selection_mode(Gtk.SelectionMode.NONE)
        windows_container.set_size_request(width - 20, height - 50)  # Account for header and padding
        
        # Add windows to this workspace
        window_scale = 0.12  # Slightly smaller scale to fit better
        
        if workspace_clients:
            # Limit to first 6 windows to prevent overflow
            for client in workspace_clients[:6]:
                window_widget = WindowWidget(client, window_scale, overview_widget)
                windows_container.add(window_widget)
            
            # Show indicator if there are more windows
            if len(workspace_clients) > 6:
                more_label = Label(
                    label=f"+{len(workspace_clients) - 6} more",
                    style="color: rgba(255, 255, 255, 0.5); font-size: 8px; font-style: italic;"
                )
                windows_container.add(more_label)
        else:
            # Empty workspace indicator
            empty_label = Label(
                label="Empty workspace",
                style="color: rgba(255, 255, 255, 0.5); font-size: 10px; font-style: italic;"
            )
            empty_label.set_halign(Gtk.Align.CENTER)
            empty_label.set_valign(Gtk.Align.CENTER)
            windows_container.add(empty_label)
        
        main_container.add(windows_container)
        
        self.add(main_container)
        
        # Style based on active state
        if is_active:
            border_style = "border: 2px solid rgba(100, 150, 255, 1);"
            bg_style = "background: rgba(100, 150, 255, 0.2);"
        else:
            border_style = "border: 1px solid rgba(255, 255, 255, 0.3);"
            bg_style = "background: rgba(255, 255, 255, 0.05);"
        
        self.set_style(f"{bg_style} {border_style} border-radius: 8px; margin: 8px; padding: 8px;")
        
        # Connect click event for window focusing only
        # Removed workspace switching click event
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
        current_style = self.get_style_context()
        if "rgba(100, 150, 255" in str(current_style):  # Active workspace
            self.set_style(
                "background: rgba(100, 150, 255, 0.3); "
                "border: 2px solid rgba(100, 150, 255, 1); "
                "border-radius: 8px; margin: 8px; padding: 8px;"
            )
        else:  # Inactive workspace
            self.set_style(
                "background: rgba(255, 255, 255, 0.1); "
                "border: 1px solid rgba(255, 255, 255, 0.5); "
                "border-radius: 8px; margin: 8px; padding: 8px;"
            )
        return False
    
    def on_leave(self, widget, event):
        """Remove highlight"""
        if hasattr(self, 'workspace_id'):
            # Restore original style based on active state
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


def main(width_percent=70, height_percent=60):
    """Enhanced main function with window thumbnails"""
    
    print("Debug: Starting Enhanced Hyprland Overview")
    
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
    overview_width = int(screen_width * (width_percent / 100))
    overview_height = int(screen_height * (height_percent / 100))
    
    print(f"Debug: Screen size: {screen_width}x{screen_height}")
    print(f"Debug: Calculated overview size: {overview_width}x{overview_height}")
    
    # Create main container without setting size here - let window handle it
    main_container = Box(
        orientation="v",
        spacing=15,
        style="padding: 20px; background-color: rgba(30, 30, 46, 0.95); border-radius: 12px;"
    )
    
    # Create workspace grid - no scrolling, everything fits in main window
    workspace_grid = Gtk.FlowBox()
    workspace_grid.set_max_children_per_line(3)
    workspace_grid.set_column_spacing(10)
    workspace_grid.set_row_spacing(10)
    workspace_grid.set_homogeneous(True)
    workspace_grid.set_selection_mode(Gtk.SelectionMode.NONE)
    
    # Calculate workspace size based on overview container size
    # Account for padding, spacing, and margins
    available_width = overview_width - 60  # padding + margins
    available_height = overview_height - 60  # padding + margins
    
    # Calculate size for 3 columns and up to 4 rows (12 workspaces max)
    workspace_width = (available_width - 20) // 3  # 20 for column spacing
    workspace_height = (available_height - 30) // 4  # 30 for row spacing
    
    print(f"Debug: Available space: {available_width}x{available_height}")
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
    
    # Create centered window with explicit size control
    window = Window(
        child=main_container,
        layer="overlay",
        anchor="",  # Center the window
        keyboard_mode="on-demand",
        margin="0px",
        # Remove CSS size constraints and handle sizing programmatically
        on_destroy=lambda w, *_: w.application.quit()
    )
    
    print("Debug: Window created")
    
    # Set window size constraints - this is the key change
    window.set_default_size(overview_width, overview_height)
    window.set_size_request(overview_width, overview_height)
    
    # Also set the main container size to match
    main_container.set_size_request(overview_width, overview_height)
    workspace_grid.set_size_request(overview_width - 40, overview_height - 40)
    
    # For Wayland windows, we might need to handle sizing differently
    def on_window_realize(widget):
        """Handle window realization to ensure proper sizing"""
        try:
            # Try to resize the window after it's realized
            if hasattr(widget, 'resize'):
                widget.resize(overview_width, overview_height)
            print(f"Debug: Window realized with target size {overview_width}x{overview_height}")
        except Exception as e:
            print(f"Debug: Could not resize window: {e}")
    
    window.connect("realize", on_window_realize)
    
    # Add keybindings
    window.add_keybinding("Escape", lambda w, *_: w.application.quit())
    window.add_keybinding("F5", lambda w, *_: main(width_percent, height_percent))  # Refresh with same params
    
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
    width_percent = 70  # default
    height_percent = 60  # default
    
    if len(sys.argv) > 1:
        try:
            width_percent = int(sys.argv[1])
        except ValueError:
            print("Invalid width percentage, using default 70%")
    
    if len(sys.argv) > 2:
        try:
            height_percent = int(sys.argv[2])
        except ValueError:
            print("Invalid height percentage, using default 60%")
    
    print(f"Debug: Starting with dimensions {width_percent}% x {height_percent}%")
    
    try:
        main(width_percent, height_percent)
    except Exception as e:
        import traceback
        print(f"Error: {e}")
        print(traceback.format_exc())
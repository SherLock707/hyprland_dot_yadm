#!/usr/bin/env python3

"""
Fixed Hyprland Overview Widget - Eliminated Right-Side Gap in Workspace Boxes
FIXED: Proper scaling to use full available width without gaps
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
        if window_height > 25:
            title_label = Label(
                label=title_text,
                style="color: white; font-size: 8px; font-weight: bold;"
            )
            title_label.set_halign(Gtk.Align.CENTER)
            window_content.add(title_label)
        
        # Show class if there's enough space
        if window_height > 45:
            class_label = Label(
                label=self.window_class[:max_chars],
                style="color: rgba(255, 255, 255, 0.7); font-size: 6px;"
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
            "border-radius: 2px; "
            "padding: 1px;"
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
                "border-radius: 2px; "
                "padding: 1px;"
            )
        else:
            self.set_style(
                "background: rgba(255, 255, 255, 0.2); "
                "border: 1px solid rgba(255, 255, 255, 0.6); "
                "border-radius: 2px; "
                "padding: 1px;"
            )
        return False
    
    def on_leave(self, widget, event):
        """Remove highlight"""
        if self.client.get("floating", False):
            self.set_style(
                "background: rgba(255, 200, 100, 0.15); "
                "border: 1px solid rgba(255, 200, 100, 0.8); "
                "border-radius: 2px; "
                "padding: 1px;"
            )
        else:
            self.set_style(
                "background: rgba(255, 255, 255, 0.1); "
                "border: 1px solid rgba(255, 255, 255, 0.4); "
                "border-radius: 2px; "
                "padding: 1px;"
            )
        return False


class WorkspaceWidget(EventBox):
    """Fixed workspace widget - eliminated right-side gap by using full available width"""
    
    def __init__(self, workspace: Dict, clients: List[Dict], is_active: bool, overview_widget, width: int, height: int, monitor_info: Dict, effective_monitor_width: int, effective_monitor_height: int):
        super().__init__()
        self.workspace = workspace
        self.workspace_id = workspace.get("id", 0)
        self.overview_widget = overview_widget
        self.monitor_info = monitor_info
        self.effective_monitor_width = effective_monitor_width
        self.effective_monitor_height = effective_monitor_height
        
        # FIXED: Reduced padding to eliminate right-side gap
        self.padding_left = 0
        self.padding_right = 0
        self.padding_bottom = 2
        self.padding_top = 0
        
        # Use provided dimensions
        self.set_size_request(width, height)
        
        # Create main container
        main_container = Box(orientation="v", spacing=1)
        
        # Workspace header (compact)
        header = Box(orientation="h", spacing=8)
        
        # Workspace number/name
        ws_name = workspace.get("name", str(self.workspace_id))
        header_label = Label(
            label=f"WS {ws_name}",
            style="color: white; font-size: 9px; font-weight: bold;"
        )
        header_label.set_halign(Gtk.Align.START)
        header.add(header_label)
        
        # Window count
        workspace_clients = [c for c in clients if c.get("workspace", {}).get("id") == self.workspace_id]
        count_label = Label(
            label=f"({len(workspace_clients)})",
            style="color: rgba(255, 255, 255, 0.7); font-size: 8px;"
        )
        count_label.set_halign(Gtk.Align.END)
        header.add(count_label)
        
        main_container.add(header)
        
        # FIXED: Recalculated available space with reduced padding
        widget_padding = 8  # Reduced from 12
        header_height = 12   # Reduced from 15
        
        # The total available space within the widget
        total_available_width = width - widget_padding
        total_available_height = height - widget_padding - header_height
        
        # The usable space for windows (now uses almost full width)
        usable_width = total_available_width - self.padding_left - self.padding_right
        usable_height = total_available_height - self.padding_bottom
        
        print(f"Debug: Workspace {self.workspace_id} - Widget: {width}x{height}")
        print(f"Debug: Total available: {total_available_width}x{total_available_height}")
        print(f"Debug: Usable for windows: {usable_width}x{usable_height}")
        
        if workspace_clients:
            # Create workspace container using Gtk.Layout for absolute positioning
            workspace_container = Gtk.Layout()
            workspace_container.set_size_request(total_available_width, total_available_height)
            
            # Find the actual bounds of windows on this workspace
            min_x = float('inf')
            max_x = float('-inf')
            min_y = float('inf')
            max_y = float('-inf')
            
            # Get monitor offset
            monitor_x = self.monitor_info.get("x", 0)  
            monitor_y = self.monitor_info.get("y", 0)
            waybar_height = 30
            
            # Find the actual bounding box of all windows
            for client in workspace_clients:
                window_at = client.get("at", [0, 0])
                window_size = client.get("size", [200, 150])
                
                # Convert to monitor-relative coordinates
                relative_x = window_at[0] - monitor_x
                relative_y = window_at[1] - monitor_y
                
                # Adjust for waybar
                if relative_y >= waybar_height:
                    relative_y -= waybar_height
                else:
                    relative_y = 0
                
                # Update bounds
                min_x = min(min_x, relative_x)
                max_x = max(max_x, relative_x + window_size[0])
                min_y = min(min_y, relative_y)
                max_y = max(max_y, relative_y + window_size[1])
            
            # If we have valid bounds, use them; otherwise fall back to effective monitor size
            if min_x != float('inf') and max_x != float('-inf'):
                content_width = max_x - min_x
                content_height = max_y - min_y
                
                # FIXED: Ensure we always use minimum monitor dimensions to avoid excessive scaling
                content_width = max(content_width, self.effective_monitor_width * 0.8)
                content_height = max(content_height, self.effective_monitor_height * 0.8)
                
                print(f"Debug: Actual window bounds: {min_x},{min_y} to {max_x},{max_y}")
                print(f"Debug: Content dimensions: {content_width}x{content_height}")
            else:
                # Fallback to effective monitor dimensions
                content_width = self.effective_monitor_width
                content_height = self.effective_monitor_height
                min_x = 0
                min_y = 0
            
            # FIXED: Calculate scale factors to fully utilize available space
            scale_x = usable_width / content_width
            scale_y = usable_height / content_height
            
            # Use uniform scaling to maintain aspect ratio but ensure full width usage
            scale = min(scale_x, scale_y)
            
            # FIXED: If width is the limiting factor, stretch slightly to use full width
            if scale_x <= scale_y:
                # Width-limited: use full width
                final_scale_x = scale_x
                final_scale_y = scale_y * (scale_x / scale_y) * 0.95  # Slight adjustment
            else:
                # Height-limited: maintain proportions
                final_scale_x = scale_x
                final_scale_y = scale_y
            
            print(f"Debug: Workspace {self.workspace_id} - Scale factors: x={final_scale_x:.4f}, y={final_scale_y:.4f}")
            
            # Position each window using the calculated scale factors
            for client in workspace_clients:
                # Get window position and size (absolute coordinates)
                window_at = client.get("at", [0, 0])
                window_size = client.get("size", [200, 150])
                
                # Convert to monitor-relative coordinates
                relative_x = window_at[0] - monitor_x  
                relative_y = window_at[1] - monitor_y
                
                # Adjust for waybar space
                if relative_y >= waybar_height:
                    relative_y -= waybar_height
                else:
                    relative_y = 0
                
                # Convert to content-relative coordinates
                content_relative_x = relative_x - min_x
                content_relative_y = relative_y - min_y
                
                # FIXED: Apply the new scaling to use full available width
                scaled_x = int(content_relative_x * final_scale_x) + self.padding_left
                scaled_y = int(content_relative_y * final_scale_y) + self.padding_top
                
                # Scale window size
                scaled_width = max(8, int(window_size[0] * final_scale_x))
                scaled_height = max(6, int(window_size[1] * final_scale_y))
                
                # FIXED: Ensure windows can use the full available space
                max_x_pos = usable_width + self.padding_left - scaled_width
                max_y_pos = usable_height + self.padding_top - scaled_height
                
                # Clamp position to stay within bounds
                scaled_x = max(self.padding_left, min(scaled_x, max_x_pos))
                scaled_y = max(self.padding_top, min(scaled_y, max_y_pos))
                
                # Ensure size doesn't exceed available space from current position
                available_width_from_pos = usable_width + self.padding_left - scaled_x
                available_height_from_pos = usable_height + self.padding_top - scaled_y
                scaled_width = min(scaled_width, max(8, available_width_from_pos))
                scaled_height = min(scaled_height, max(6, available_height_from_pos))
                
                print(f"Debug: Window '{client.get('class', 'Unknown')}':")
                print(f"  Original: pos({window_at[0]}, {window_at[1]}) size({window_size[0]}x{window_size[1]})")
                print(f"  Content-relative: pos({content_relative_x}, {content_relative_y})")
                print(f"  Final: pos({scaled_x}, {scaled_y}) size({scaled_width}x{scaled_height})")
                
                # Create window widget
                window_widget = WindowWidget(client, scaled_width, scaled_height, overview_widget)
                
                # Position the window widget
                workspace_container.put(window_widget, scaled_x, scaled_y)
            
            main_container.add(workspace_container)
            
        else:
            # Empty workspace indicator
            empty_label = Label(
                label="Empty",
                style="color: rgba(255, 255, 255, 0.5); font-size: 10px; font-style: italic;"
            )
            empty_label.set_halign(Gtk.Align.CENTER)
            empty_label.set_valign(Gtk.Align.CENTER)
            empty_label.set_size_request(usable_width, usable_height)
            
            # Create a container with padding for the empty label
            empty_container = Gtk.Layout()
            empty_container.set_size_request(total_available_width, total_available_height)
            empty_container.put(empty_label, self.padding_left + (usable_width - 50) // 2, self.padding_top + (usable_height - 20) // 2)
            
            main_container.add(empty_container)
        
        self.add(main_container)
        
        # Style based on active state
        if is_active:
            border_style = "border: 2px solid rgba(100, 150, 255, 1);"
            bg_style = "background: rgba(100, 150, 255, 0.2);"
        else:
            border_style = "border: 1px solid rgba(255, 255, 255, 0.3);"
            bg_style = "background: rgba(255, 255, 255, 0.05);"
        
        self.set_style(f"{bg_style} {border_style} border-radius: 6px; padding: 6px; margin: 3px;")
        
        # Connect hover events
        self.connect("enter-notify-event", self.on_enter)
        self.connect("leave-notify-event", self.on_leave)
        
        # Add click handler to switch to workspace
        self.connect("button-press-event", self.on_workspace_click)
        
    def on_workspace_click(self, widget, event):
        """Handle workspace click - switch to workspace"""
        if event.button == 1:
            print(f"Switching to workspace: {self.workspace_id}")
            try:
                exec_shell_command(f"hyprctl dispatch workspace {self.workspace_id}")
                self.overview_widget.close_overview()
            except Exception as e:
                print(f"Error switching workspace: {e}")
        return True
        
    def on_enter(self, widget, event):
        """Highlight on hover"""
        active_workspace = HyprlandClient.get_active_workspace()
        is_active = self.workspace_id == active_workspace.get("id", -1)
        
        if is_active:
            self.set_style(
                "background: rgba(100, 150, 255, 0.3); "
                "border: 2px solid rgba(100, 150, 255, 1); "
                "border-radius: 6px; padding: 6px; margin: 3px;"
            )
        else:
            self.set_style(
                "background: rgba(255, 255, 255, 0.1); "
                "border: 1px solid rgba(255, 255, 255, 0.5); "
                "border-radius: 6px; padding: 6px; margin: 3px;"
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
                "border-radius: 6px; padding: 6px; margin: 3px;"
            )
        else:
            self.set_style(
                "background: rgba(255, 255, 255, 0.05); "
                "border: 1px solid rgba(255, 255, 255, 0.3); "
                "border-radius: 6px; padding: 6px; margin: 3px;"
            )
        return False


def main(percent=70):
    """Main function with improved scaling to eliminate gaps"""
    
    print("Debug: Starting Fixed Hyprland Overview - No Right Gap")
    
    # Get data from Hyprland
    workspaces = HyprlandClient.get_workspaces()
    clients = HyprlandClient.get_clients()
    active_workspace = HyprlandClient.get_active_workspace()
    monitors = HyprlandClient.get_monitors()
    
    active_id = active_workspace.get("id", -1)
    
    print(f"Debug: Found {len(workspaces)} workspaces, {len(clients)} windows")
    print(f"Debug: Active workspace: {active_id}")
    
    # Get primary monitor info
    monitor_info = monitors[0] if monitors else {"width": 3440, "height": 1440, "x": 0, "y": 0}
    monitor_width = monitor_info.get("width", 3440)
    monitor_height = monitor_info.get("height", 1440)
    
    # Calculate effective monitor dimensions for window positioning
    waybar_height = 30
    effective_monitor_width = monitor_width
    effective_monitor_height = monitor_height - waybar_height
    effective_monitor_aspect = effective_monitor_width / effective_monitor_height
    
    print(f"Debug: Monitor: {monitor_width}x{monitor_height}")
    print(f"Debug: Effective (for window scaling): {effective_monitor_width}x{effective_monitor_height}")
    print(f"Debug: Effective aspect ratio: {effective_monitor_aspect:.2f}")
    
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
    screen_aspect = screen_width / screen_height
    
    # Use configurable percentage of screen width and height
    overview_width = int(screen_width * (percent / 100))
    overview_height = int(screen_height * (percent / 100))
    
    print(f"Debug: Screen size: {screen_width}x{screen_height} (aspect: {screen_aspect:.2f})")
    print(f"Debug: Overview size: {overview_width}x{overview_height}")
    
    # Use fixed 5x2 grid layout
    cols = 5
    rows = 2
    print(f"Debug: Using fixed grid layout: {cols}x{rows}")
    
    # Create main container
    main_container = Box(
        orientation="v",
        spacing=10,
        style="padding: 15px; background-color: rgba(30, 30, 46, 0.95); border-radius: 12px;"
    )
    
    # Create workspace grid using Gtk.Grid for better control  
    workspace_grid = Gtk.Grid()
    workspace_grid.set_column_spacing(6)
    workspace_grid.set_row_spacing(6)
    workspace_grid.set_column_homogeneous(True)
    workspace_grid.set_row_homogeneous(True)
    workspace_grid.set_halign(Gtk.Align.CENTER)
    workspace_grid.set_valign(Gtk.Align.CENTER)
    
    # Calculate workspace size maintaining effective display aspect ratio
    available_width = overview_width - 50
    available_height = overview_height - 50
    
    # Calculate individual workspace size accounting for grid spacing
    total_h_spacing = (cols - 1) * 6
    total_v_spacing = (rows - 1) * 6
    
    # Available space for actual workspace widgets
    grid_content_width = available_width - total_h_spacing
    grid_content_height = available_height - total_v_spacing
    
    # Calculate workspace dimensions using the effective aspect ratio
    workspace_width_by_width = grid_content_width // cols
    workspace_height_by_width = int(workspace_width_by_width / effective_monitor_aspect)
    
    workspace_height_by_height = grid_content_height // rows
    workspace_width_by_height = int(workspace_height_by_height * effective_monitor_aspect)
    
    # Choose the option that fits within available space
    if workspace_height_by_width <= grid_content_height // rows:
        workspace_width = workspace_width_by_width
        workspace_height = workspace_height_by_width
        print(f"Debug: Using width-constrained sizing")
    else:
        workspace_width = workspace_width_by_height
        workspace_height = workspace_height_by_height
        print(f"Debug: Using height-constrained sizing")
    
    # Ensure minimum size while maintaining effective aspect ratio
    min_width = 200
    min_height = int(min_width / effective_monitor_aspect)
    
    if workspace_width < min_width:
        workspace_width = min_width
        workspace_height = min_height
    
    print(f"Debug: Grid layout - Available: {available_width}x{available_height}")
    print(f"Debug: Spacing - H: {total_h_spacing}, V: {total_v_spacing}")
    print(f"Debug: Individual workspace size: {workspace_width}x{workspace_height}")
    print(f"Debug: Workspace aspect ratio: {workspace_width/workspace_height:.2f} (target: {effective_monitor_aspect:.2f})")
    
    # Set the grid size explicitly
    grid_width = workspace_width * cols + total_h_spacing
    grid_height = workspace_height * rows + total_v_spacing
    workspace_grid.set_size_request(grid_width, grid_height)
    
    class OverviewApp:
        def __init__(self, app=None):
            self.app = app
        
        def close_overview(self):
            if self.app:
                self.app.quit()
    
    overview_app = OverviewApp()
    
    # Add workspace widgets to grid
    for i, workspace in enumerate(workspaces):
        if i >= cols * rows:
            break
            
        workspace_id = workspace.get("id", 0)
        is_active = workspace_id == active_id
        workspace_widget = WorkspaceWidget(
            workspace, clients, is_active, overview_app, 
            workspace_width, workspace_height, monitor_info,
            effective_monitor_width, effective_monitor_height
        )
        
        # Calculate grid position
        row = i // cols
        col = i % cols
        workspace_grid.attach(workspace_widget, col, row, 1, 1)
    
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
    
    # Add keybindings
    window.add_keybinding("Escape", lambda w, *_: w.application.quit())
    window.add_keybinding("F5", lambda w, *_: main(percent))
    
    # Create application
    app = Application("hyprland-overview", window)
    overview_app.app = app
    
    print("Debug: Application created, showing window")
    
    # Show everything
    main_container.show_all()
    window.show_all()
    
    # Run
    app.run()


if __name__ == "__main__":
    import sys
    
    # Allow configurable width and height via command line arguments
    percent = 70
    
    if len(sys.argv) > 1:
        try:
            percent = int(sys.argv[1])
        except ValueError:
            print("Invalid percentage, using default 70%")
    
    print(f"Debug: Starting with dimensions {percent}%")
    
    try:
        main(percent)
    except Exception as e:
        import traceback
        print(f"Error: {e}")
        print(traceback.format_exc())
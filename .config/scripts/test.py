# #!/usr/bin/env python3
# import os
# import gi
# gi.require_version("Gtk", "3.0")

# from gi.repository import Gio, Gtk

# DESKTOP_DIRS = [
#     "/usr/share/applications",
#     os.path.expanduser("~/.local/share/applications"),
# ]

# def find_desktop_file(app_name):
#     for base in DESKTOP_DIRS:
#         for fname in os.listdir(base):
#             if not fname.endswith(".desktop"):
#                 continue
#             if app_name.lower() in fname.lower():
#                 return os.path.join(base, fname)
#     return None

# def get_icon_path_from_desktop_file(path, size=64):
#     if not os.path.exists(path):
#         return None

#     app_info = Gio.DesktopAppInfo.new_from_filename(path)
#     icon = app_info.get_icon()

#     if not icon:
#         return None

#     theme = Gtk.IconTheme.get_default()

#     if isinstance(icon, Gio.ThemedIcon):
#         print("first instance")
#         for name in icon.get_names():
#             info = theme.lookup_icon(name, size, 0)
#             if info:
#                 return info.get_filename()
#     elif isinstance(icon, Gio.FileIcon):
#         print("Second instance")
#         return icon.get_file().get_path()

#     return None

# def get_icon_for_app(app_name):
#     desktop = find_desktop_file(app_name)
#     print(desktop)
#     if desktop:
#         return get_icon_path_from_desktop_file(desktop)
#     return None

# # Batch mode: list of app names
# if __name__ == "__main__":
#     import sys
#     if len(sys.argv) < 2:
#         print("Usage: ./get_icons.py app1 app2 app3 ...")
#         sys.exit(1)

#     for app in sys.argv[1:]:
#         icon = get_icon_for_app(app)
#         print(f"{app}: {icon if icon else '❌ Not Found'}")


from hyprpy import Hyprland

instance = Hyprland()



monitors = instance.get_monitors()
mon_list = []
for mon in monitors:
    mon_list.append({'id': mon.id, 'name': mon.name, 'width': mon.width, 'height': mon.height})
print(mon_list)

active_ws = instance.get_active_workspace()
active_ws_id = {'id': active_ws.id}
print(active_ws_id)

workspace = instance.get_workspaces()
ws_list = []
for ws in workspace:
    ws_list.append({'id': ws.id, 'name': ws.name, 'monitor': ws.monitor_name, 'monitorID': ws.monitor.id, 'windows': ws.window_count})
print(ws_list)

clients = instance.get_windows()
cl_list = []
for cl in clients:
    cl_list.append({'address': cl.address, 'at': [cl.position_x, cl.position_y], 'workspace': {'id': cl.workspace_id, 'name':cl.workspace_name},
                    'floating': cl.is_floating, 'class': cl.wm_class, 'title': cl.title, 'pid': cl.pid})
print(cl_list)
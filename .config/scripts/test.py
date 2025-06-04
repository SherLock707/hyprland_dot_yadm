#!/usr/bin/env python3
import os
import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gio, Gtk

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
        return None

    app_info = Gio.DesktopAppInfo.new_from_filename(path)
    icon = app_info.get_icon()

    if not icon:
        return None

    theme = Gtk.IconTheme.get_default()

    if isinstance(icon, Gio.ThemedIcon):
        print("first instance")
        for name in icon.get_names():
            info = theme.lookup_icon(name, size, 0)
            if info:
                return info.get_filename()
    elif isinstance(icon, Gio.FileIcon):
        print("Second instance")
        return icon.get_file().get_path()

    return None

def get_icon_for_app(app_name):
    desktop = find_desktop_file(app_name)
    print(desktop)
    if desktop:
        return get_icon_path_from_desktop_file(desktop)
    return None

# Batch mode: list of app names
if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: ./get_icons.py app1 app2 app3 ...")
        sys.exit(1)

    for app in sys.argv[1:]:
        icon = get_icon_for_app(app)
        print(f"{app}: {icon if icon else '❌ Not Found'}")

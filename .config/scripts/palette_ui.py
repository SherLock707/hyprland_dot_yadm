import os
import json
import re
import pyperclip
from functools import partial

from fabric import Application
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from fabric.utils import exec_shell_command_async
from fabric.widgets.wayland import WaylandWindow as Window

# Constants
USER=os.path.expanduser("~")
THEME_PATH = f"{USER}/.config/hellwal/themes/custom.hellwal"
WALLPAPER_PATH = f"{USER}/.config/rofi/.current_wallpaper"
SCRIPT_PATH = f"{USER}/.config/hypr/scripts/PywalSwww.sh"
COLOR_JSON_PATH = f"{USER}/.cache/hellwal/colors.json"

# Global color dictionary
color_dict = {}

# Color cache for performance
_complementary_cache = {}

# ===================== Core Logic =====================

def apply_color(color_button, label, color):
    color = color.strip()
    if not color.startswith('#'):
        return  # skip invalid
    color_button.set_style(f"background: {color}; color: {complementary_color(color)}; font-weight: bold;")
    color_dict[label] = color

def pick_color(label, color_button):
    current_color = color_dict[label]
    cmd = f"kcolorchooser --color={current_color} --print"
    return exec_shell_command_async(cmd, lambda result: apply_color(color_button, label, result))

def copy_to_clipboard(text):
    try:
        pyperclip.copy(text)
    except pyperclip.PyperclipException:
        print("Clipboard not available on this system.")


def read_color(path: str) -> dict:
    try:
        with open(os.path.expanduser(path), 'r', encoding='utf-8') as f:
            return json.load(f)
    except (json.JSONDecodeError, FileNotFoundError) as e:
        print(f"Failed to load color file: {e}")
        return {}

def write_theme(path: str):
    with open(path, 'w', encoding='utf-8') as f:
        for key, value in color_dict.items():
            f.write(f"%% {key}  = {value} %%\n")

def complementary_color(hex_color: str) -> str:
    if hex_color in _complementary_cache:
        return _complementary_cache[hex_color]
    hex_color = hex_color.lstrip('#')
    if len(hex_color) != 6:
        return '#ffffff'
    try:
        r, g, b = int(hex_color[0:2], 16), int(hex_color[2:4], 16), int(hex_color[4:6], 16)
    except ValueError:
        return '#ffffff'
    brightness = 0.299 * r + 0.587 * g + 0.114 * b
    result = '#000000' if brightness > 186 else '#ffffff'
    _complementary_cache[hex_color] = result
    return result

def refresh_theme():
    print("Refreshing theme...")
    write_theme(THEME_PATH)
    if os.path.exists(THEME_PATH):
        exec_shell_command_async(f"{SCRIPT_PATH} theme-only")

# ===================== UI Components =====================

def color_button(label: str) -> Button:
    color = color_dict[label]
    return Button(
        label=label,
        style=f"background: {color}; color: {complementary_color(color)}; font-weight: bold;",
        h_expand=True
    )

def copy_button(label):
    return Button(label="󰆏", style="min-width: 5px;", on_clicked=lambda *_: copy_to_clipboard(color_dict[label]))

def edit_button(label, colour_btn):
    return Button(label="", style="min-width: 5px;", on_clicked=lambda *_: pick_color(label, colour_btn))

def make_color_row(label: str) -> Box:
    color_btn = color_button(label)
    return Box(
        spacing=12,
        orientation="h",
        children=[
            copy_button(label),
            color_btn,
            edit_button(label, color_btn)
        ]
    )

# ===================== Main Application =====================

def main():
    global color_dict
    color_dict = read_color(COLOR_JSON_PATH)

    img = Image(WALLPAPER_PATH, size=(400, -1))

    box_main = Box(
        orientation="v",
        spacing=5,
        style=f"padding: 10px; border: 2px solid {color_dict.get('color7', '#ffffff')}; border-bottom: 4.5px solid {color_dict.get('color7', '#ffffff')}; border-radius: 20px; background-color: alpha(#1e1e2e, 0.7);",
    )
    box_main.add(img)

    for label in color_dict:
        box_main.add(make_color_row(label))

    box_main.add(Button(label="", on_clicked=lambda *_: refresh_theme()))

    window = Window(
        child=box_main,
        layer="overlay",
        anchor="top left",
        keyboard_mode="on-demand",
        margin="10px 0px 0px 350px",
        style=f"background-color: transparent;",
        on_destroy=lambda w, *_: w.application.quit()
    )

    window.add_keybinding("Escape", lambda w, *_: w.application.quit())

    app = Application("palette-app", window)
    app.run()

if __name__ == "__main__":
    main()

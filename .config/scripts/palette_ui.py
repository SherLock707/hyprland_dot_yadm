import os
import json
import pyperclip

from fabric import Application
from fabric.widgets.box import Box
from fabric.widgets.label import Label
# from fabric.widgets.window import Window
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from fabric.utils import exec_shell_command_async
from fabric.widgets.wayland import WaylandWindow as Window

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

def apply_color(color_button, label, color):
    color_button.set_style(f"background: {color}")
    color_dict[label] = color
    # write_css_colors(color_dict, "~/.cache/hellwal/colors-waybar_updated.css")

def pick_color(label, color_button):
    return exec_shell_command_async(f"kcolorchooser --color={color_dict[label]} --print", lambda result: apply_color(color_button, label, result))

def copy_to_clipboard(text):
    try:
        pyperclip.copy(text)
    except pyperclip.PyperclipException:
        print("Pyperclip could not find a copy/paste mechanism for your system.")

def parse_css_colors(path: str) -> dict:
    path = os.path.expanduser(path)
    colors = {}
    with open(path, 'r') as f:
        for line in f:
            match = re.match(r'@define-color\s+([\w-]+)\s+(#[0-9a-fA-F]{6});', line.strip())
            if match:
                var, color = match.groups()
                colors[var] = color.lower()
    return colors

def write_css_colors(colors: dict, path: str):
    path = os.path.expanduser(path)
    lines = [f"@define-color {key} {value};\n" for key, value in colors.items()]
    with open(path, 'w') as f:
        f.writelines(lines)

def read_color(path):
    """Reads and returns data from a JSON file."""
    path = os.path.expanduser(path)
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def write_theme(path):
    """Writes the color dictionary to a .hellwal theme file in custom format."""
    with open(path, 'w', encoding='utf-8') as f:
        for key, value in color_dict.items():
            f.write(f"%% {key}  = {value} %%\n")


def complementary_color(hex_color: str) -> str:
    hex_color = hex_color.lstrip('#')
    if len(hex_color) != 6:
        raise ValueError("Invalid hex color format. Must be #RRGGBB")
    try:
        r = int(hex_color[0:2], 16)
        g = int(hex_color[2:4], 16)
        b = int(hex_color[4:6], 16)
    except ValueError:
        raise ValueError("Invalid hexadecimal characters in the color code.")
    brightness = 0.299 * r + 0.587 * g + 0.114 * b
    return '#000000' if brightness > 186 else '#ffffff'

def copy_button(label):
    return Button(label="󰆏", style="min-width: 5px;", on_clicked=lambda *_: copy_to_clipboard(color_dict[label]))

def edit_button(label, colour_btn):
    return Button(label="", style="min-width: 5px;", on_clicked=lambda *_: pick_color(label, colour_btn))

def color_button(label):
    return Button(label=label, style=f"background: {color_dict[label]}; color: {complementary_color(color_dict[label])}; font-weight: bold;", h_expand=True)

def refresh_theme():
    print("refreshing!")
    theme_path = os.path.expanduser("~/.config/hellwal/themes/custom.hellwal")
    write_theme(theme_path)
    if os.path.exists(theme_path):
        exec_shell_command_async(f"{os.path.expanduser('~/.config/hypr/scripts/PywalSwww.sh')} theme-only")


color_dict = read_color("~/.cache/hellwal/colors.json")

if __name__ == "__main__":
    img = Image('/home/itachi/.config/rofi/.current_wallpaper', size=(400,-1))
    box_main = Box(
        orientation="v",
        spacing=5,
        style="padding: 10px;"
    )
    box_main.add(img)
    for name, _ in color_dict.items():
        colour_btn = color_button(name)
        box_main.add(
            Box(
                spacing=12,
                orientation="h",
                children=[
                    copy_button(name),
                    colour_btn,
                    edit_button(name, colour_btn)
                ]
            )
        )

    box_main.add(
       Button(label="", on_clicked=lambda *_: refresh_theme())
    )

    window = Window(
        child=box_main,
        type='popup',
        WindowType = Gtk.WindowType.TOPLEVEL,
        layer="overlay",
        anchor="top left",
        keyboard_mode='on-demand',
        margin='10px 0px 0px 350px', #“top right bottom left”
        style=f"background : #1E1E2E; border: 2px solid {color_dict['color7']}; border-radius: 10px;",
        on_destroy=lambda w, *_: w.application.quit()
    )
    window.add_keybinding("Escape", lambda w, *_: w.application.quit())

    app = Application("palette-app", window)

    app.run()
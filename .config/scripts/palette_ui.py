import os
import re
import pyperclip

from fabric import Application
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.window import Window
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from fabric.utils import exec_shell_command_async
from fabric.widgets.wayland import WaylandWindow


def apply_color(color_button, label, color):
    color_button.set_style(f"background: {color}")
    color_dict[label] = color
    write_css_colors(color_dict, "~/.cache/hellwal/colors-waybar_updated.css")

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
    return Button(label="󰆏", on_clicked=lambda *_: copy_to_clipboard(color_dict[label]))

def edit_button(label, colour_btn):
    return Button(label="", on_clicked=lambda *_: pick_color(label, colour_btn))

def color_button(label):
    return Button(label=label, style=f"background: {color_dict[label]}; color: {complementary_color(color_dict[label])}; font-weight: bold;", h_expand=True)


color_dict = parse_css_colors("~/.cache/hellwal/colors-waybar.css")

if __name__ == "__main__":
    img = Image('/home/itachi/.config/rofi/.current_wallpaper', size=(400,-1))
    box_main = Box(
        orientation="v",
        spacing=5
    )
    box_main.add(img)
    for name, _ in color_dict.items():
        colour_btn = color_button(name)
        box_tmp = Box(
            spacing=12,
            orientation="h",
            children=[
                colour_btn,
                copy_button(name),
                edit_button(name, colour_btn)
            ]
        )

        box_main.add(box_tmp)

    window = Window(
        child=box_main,
        type='popup',
        on_destroy=lambda w, *_: w.application.quit()
    )
    window.add_keybinding("Escape", lambda w, *_: w.application.quit())

    app = Application("palette-app", window)

    app.run()
import fabric
from fabric import Application
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.window import Window
from fabric.widgets.button import Button
from fabric.utils import exec_shell_command_async, idle_add

import os
import re
import pyperclip

import subprocess

def apply_color(color_button, label, color):
    color_button.set_style(f"background: {color}")
    color_dict[label] = color
    write_css_colors(color_dict, "~/.cache/hellwal/colors-waybar_updated.css")

def pick_color(label, color_button):
    return exec_shell_command_async(f"kcolorchooser --color={color_dict[label]} --print", lambda result: apply_color(color_button, label, result))

def copy_to_clipboard(text):
    """Copies the given text to the clipboard."""
    try:
        pyperclip.copy(text)
        print("Text copied to clipboard!")
    except pyperclip.PyperclipException:
        print("Pyperclip could not find a copy/paste mechanism for your system.")

def parse_css_colors(path: str) -> dict:
    """Parses @define-color CSS rules into a dict."""
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
    """Writes the color dict back into CSS format at given path."""
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
    
    # Calculate luminance using perceived brightness
    brightness = 0.299 * r + 0.587 * g + 0.114 * b

    # Threshold for deciding text color (commonly 186, but 128 is stricter)
    return '#000000' if brightness > 186 else '#ffffff'

def copy_button(label): # define a "factory function"
    return Button(label="󰆏", on_clicked=lambda *_: copy_to_clipboard(color_dict[label]))

def edit_button(label, colour_btn): # define a "factory function"
    # return Button(label="", on_clicked=lambda *_: colour_btn.set_style(f"background: {pick_color(hex_value)}"))
    return Button(label="", on_clicked=lambda *_: pick_color(label, colour_btn))

def color_button(label): # define a "factory function"
    return Button(label=label, style=f"background: {color_dict[label]}; color: {complementary_color(color_dict[label])}; font-weight: bold;", h_expand=True)


color_dict = parse_css_colors("~/.cache/hellwal/colors-waybar.css")

if __name__ == "__main__":
    box_1 = Box(
        orientation="v", # vertical
        spacing=5 # adds some spacing between the children
    )
    
    for name, _ in color_dict.items():
        # print(f"{name} => {hex_value}")
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

        box_1.add(box_tmp)

    window = Window(child=box_1, type='popup')
    app = Application("palette", window)

    app.run() # run the event loop (run the config)
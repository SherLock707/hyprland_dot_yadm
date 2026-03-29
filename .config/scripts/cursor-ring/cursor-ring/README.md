# cursor-ring

A tiny, fast Wayland overlay that draws an animated shrinking ring at your
cursor position — like Windows' Ctrl+click cursor finder.

Zero persistent process. It runs, animates (~600 ms), and exits.

---

## Dependencies

| Package | Arch | Debian/Ubuntu | Fedora |
|---|---|---|---|
| GTK 4 | `gtk4` | `libgtk-4-dev` | `gtk4-devel` |
| gtk4-layer-shell | `gtk4-layer-shell` | `libgtk4-layer-shell-dev` | `gtk4-layer-shell-devel` |
| Meson + Ninja | `meson` | `meson ninja-build` | `meson ninja-build` |
| GCC | `gcc` | `gcc` | `gcc` |

```bash
# Arch
sudo pacman -S gtk4 gtk4-layer-shell meson ninja gcc

# Debian/Ubuntu (24.04+)
sudo apt install libgtk-4-dev libgtk4-layer-shell-dev meson ninja-build gcc

# Fedora
sudo dnf install gtk4-devel gtk4-layer-shell-devel meson ninja-build gcc
```

---

## Build

```bash
meson setup build
ninja -C build

# Optional: install to /usr/local/bin
sudo ninja -C build install
```

---

## Usage

```bash
# Just run it — cursor position is auto-detected
cursor-ring

# Two rings, custom colour, longer duration
cursor-ring --rings 2 --color '#00AAFF' --duration 900

# Override position manually if needed
cursor-ring --x 960 --y 540
```

Put `cursor-ring` on your PATH and bind it to a key in your compositor.

---

## All CLI options

| Flag | Type | Default | Description |
|---|---|---|---|
| `--x <int>` | int | auto | Cursor X position in screen pixels |
| `--y <int>` | int | auto | Cursor Y position in screen pixels |
| `--rings <1\|2>` | int | `1` | Number of rings |
| `--radius <float>` | float | `80` | Starting radius in pixels |
| `--duration <int>` | int | `600` | Animation duration in milliseconds |
| `--linewidth <float>` | float | `3.0` | Stroke width in pixels |
| `--color <hex>` | string | `#FF3333FF` | Ring colour as `#RRGGBB` or `#RRGGBBAA` |
| `--help` | — | — | Show help |

### Colour examples

```bash
--color '#FF3333'       # red, fully opaque
--color '#FF3333AA'     # red, 67% alpha at peak
--color '#00AAFF'       # blue
--color '#FFFF00CC'     # yellow, semi-transparent
```

---

## Compositor key binding examples

### Hyprland (`~/.config/hypr/hyprland.conf`)

```ini
bind = , F9, exec, cursor-ring-find --rings 2 --color '#FF4444' --duration 700
```

### Sway (`~/.config/sway/config`)

```
bindsym F9 exec cursor-ring-find --rings 2
```

### KDE / GNOME
Use system keyboard shortcuts, pointing to `cursor-ring-find`.

---

## How it works

1. A `gtk4-layer-shell` window is placed on the **overlay layer** (above all
   other windows), positioned so its centre is at the cursor.
2. A `GtkDrawingArea` + `GdkFrameClock` drives per-vsync redraws.
3. Cairo draws antialiased rings. Each ring's radius shrinks linearly from
   `--radius` to 0; alpha fades from `--color`'s alpha to 0.
4. With two rings, the second starts `25%` into the animation for a ripple feel.
5. The window is **input-transparent** — clicks pass through to whatever is below.
6. On animation end the process exits cleanly.

---

## Auto-detection chain

The binary tries each method in order, stopping at the first success:

| # | Method | Compositor |
|---|---|---|
| 1 | `hyprctl cursorpos` | Hyprland |
| 2 | `wlrctl pointer position` | Sway / wlroots |
| 3 | `ydotool getmouselocation` | Generic Wayland (uinput) |
| 4 | `xdotool getmouselocation` | X11 / XWayland |
| 5 | GDK pointer query | Any (if cursor over GDK surface) |
| 6 | Monitor centre | Universal fallback |

No wrapper script needed. `--x` / `--y` override if auto-detect is wrong.

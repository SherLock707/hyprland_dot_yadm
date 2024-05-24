# Hypr Sweet Catppuccin

- **Window Manager** • [Hyprland](https://github.com/hyprwm/Hyprland)🎨 Tiles
  Everywhere!
- **Shell** • [Fish](https://github.com/fish-shell/fish-shell) 🐠
  [starship](https://github.com/starship/starship) Cross Shell Platform!
- **Terminal** • [Foot](https://codeberg.org/dnkl/foot) 💻 The fast, lightweight and minimalistic Wayland terminal emulator.
- **Panel** • [Waybar](https://aur.archlinux.org/packages/waybar-hyprland-git)🍧
  Highly customizable Wayland bar for Sway and Wlroots based compositors.
- **Notify Daemon** • [Swaync](https://github.com/ErikReider/SwayNotificationCenter) 🍃
  Minimalist and functional!
- **Launcher** • [Rofi](https://github.com/davatorium/rofi) 🚀 Realmente rápido
  y customizable!
- **File Manager** • [Dolphin](https://github.com/KDE/dolphin)🐬 Featureful and reliable!

## 🖥️ Setup
![rice1](https://github.com/SherLock707/hyprland_itachi/assets/26952545/a2f9d5a2-1f47-4445-a09e-06ae6b0e5dd1)

![rice2](https://github.com/SherLock707/hyprland_itachi/assets/26952545/ca1611ac-43aa-4765-9bfc-872f0b715449)

![rice3](https://github.com/SherLock707/hyprland_itachi/assets/26952545/a6a82e2e-a45b-4ea6-acd0-3ee5b38d3cca)


## INSTALLATION (Arch Based Only)


<div align="left">

<details>
<summary><h3>Hyprland Stuff</h3></summary>

###### To get started, let's make sure we have all the necessary prerequisites. In this case, I'm using Paru as the AUR helper, but keep in mind that your system may require a different approach.

- Installation using paru

```sh
## Hyprland Stuff
paru -S hyprland-git hyprpicker-git waybar-git \
dunst nwg-look wf-recorder wlogout wlsunset
```

</details>

<details>
<summary><h3>Dependencies</h3></summary>

- Installation using paru

```sh
## Dependencies
pacman -S <>
```

</details>

<details>
<summary><h3>Apps & More</h3></summary>

```sh
## CLI & Tools
pacman -S btop cava  
```

```sh
## Browser & File Explorer
paru -S brave-bin file-roller noto-fonts noto-fonts-cjk  \
noto-fonts-emoji 
```

```sh
# Theme Based
paru -S catppuccin-gtk-theme-macchiato catppuccin-gtk-theme-mocha papirus-icon-theme sddm-git swaylock-effects-git kvantum kvantum-theme-catppuccin-git
```

```sh
# Hardware
paru -S catppuccin-gtk-theme-macchiato catppuccin-gtk-theme-mocha papirus-icon-theme sddm-git swaylock-effects-git kvantum kvantum-theme-catppuccin-git
```

</details>

</div>

<div align="left">

<details>
<summary><h3>DOTFILES</h3></summary>

```sh
git clone https://github.com/SherLock707/hyprland_itachi $HOME/Downloads/hyprland-dots/
cd $HOME/Downloads/hyprland-dots/
rsync -avxHAXP --exclude '.git*' .* ~/
```
</details>
</div>

## Credits

Built on top of : [JakooLit](https://github.com/JaKooLit/Hyprland-Dots)

---

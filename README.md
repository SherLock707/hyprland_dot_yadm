# Hyprland Arch

- **WM** • [Hyprland](https://github.com/hyprwm/Hyprland)
- **Shell** • [Fish](https://github.com/fish-shell/fish-shell)
- **Prompt** • [starship](https://github.com/starship/starship) 
- **Terminal** • [Foot](https://codeberg.org/dnkl/foot)
- **Bar** • [Waybar](https://github.com/Alexays/Waybar)
- **Notification Daemon** • [Swaync](https://github.com/ErikReider/SwayNotificationCenter) 
- **Launcher** • [Rofi](https://github.com/davatorium/rofi)
- **File Manager** • [Dolphin](https://github.com/KDE/dolphin)
- **ColourScheme Gen** • [Hellwal](https://github.com/danihek/hellwal)
- **Lockscreen** • [Hyprlock](https://github.com/hyprwm/hyprlock)
- **Scratchpad/Dropdown terminal** • [Pyprland](https://github.com/hyprland-community/pyprland)

- **Wallpaper** • [Link](https://github.com/SherLock707/hyprland_dot_yadm/tree/main/Pictures/wallpapers)
- **Font** • Open Sans
- **GTK Theme** • Catppuccin-Mocha-Mauve*
- **Qt Theme** • Catppuccin-Mocha-Mauve*
- **Cursor** • [Bibata Ice](https://github.com/ful1e5/Bibata_Cursor)
- **Icon Theme** • [BeautyLine](https://github.com/gvolpe/BeautyLine) *
*Moded

## 🖥️ Setup
### Wall
![wall](https://github.com/user-attachments/assets/a9dd667a-ff6f-4756-8de2-412ee192b340)

<details>
<summary><h3>MORE!!</h3></summary>

### Home
![home](https://github.com/user-attachments/assets/a9dd667a-ff6f-4756-8de2-412ee192b340)

### lockscreen
![lock](https://github.com/user-attachments/assets/0880ac40-a7c7-46a6-a873-e3ffa3ad7621)

### Term
![terms](https://github.com/user-attachments/assets/7d0c8232-8c2a-4991-a54c-be4552ce3b09)

### Games
![lutris](https://github.com/user-attachments/assets/1851bf2f-524d-4e0c-a0e7-8e704014042b)

### Dev
![obs_vscode](https://github.com/user-attachments/assets/b1c9ad73-38ed-41bd-8386-cb45b4ad2ab9)

### Misc1
![mix1](https://github.com/user-attachments/assets/ddfada4c-11e8-4f6e-878e-80750f670fdc)

### Misc2
![mix2](https://github.com/user-attachments/assets/77ecafde-563c-4643-a704-fe1890974d03)
</details>

---

<details>
<summary><h3>Old</h3></summary>

![rice1](https://github.com/SherLock707/hyprland_itachi/assets/26952545/a2f9d5a2-1f47-4445-a09e-06ae6b0e5dd1)

![rice2](https://github.com/SherLock707/hyprland_itachi/assets/26952545/ca1611ac-43aa-4765-9bfc-872f0b715449)

![rice3](https://github.com/SherLock707/hyprland_itachi/assets/26952545/a6a82e2e-a45b-4ea6-acd0-3ee5b38d3cca)

</details>

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

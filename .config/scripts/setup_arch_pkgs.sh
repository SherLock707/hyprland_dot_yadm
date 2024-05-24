#!/bin/bash

# chsh -s /bin/fish

# libinput debug-events --device /dev/input/event17

# fftest /dev/input/event5


# Define categories and their associated packages
declare -A categories=(
    [graphics]="package1 
                package2 
                package3"
    [system]="glibc-locales ddcutil package6"
    [tools]="bat evtest font-manager"
    [desktop]="waybar-module-pacman-updates package1"
)

# Function to install packages for a given category
install_category() {
    category=$1
    packages=${categories[$category]}

    if [ -z "$packages" ]; then
        echo "Unknown category: $category"
        exit 1
    fi

    # Install packages for the category
    sudo pacman -S --needed $packages
}

# Iterate through categories and install packages
for category in "${!categories[@]}"; do
    install_category "$category"
done


amberol
asciiquarium
beautyline
bibata-cursor-theme
blender
brave-bin
btop
btrfs-assistant
catppuccin-cursors-mocha
catppuccin-gtk-theme-mocha
cava
cliphist
cmatrix
copyq
corectrl
ddcutil
dolphin
dracula-gtk-theme-git
dracut
dunst
evtest
fastfetch
font-manager
foot
freedownloadmanager
gallery-dl
gamescope
garuda-assistant
garuda-boot-options
garuda-browser-settings
garuda-common-settings
garuda-dracut-support
garuda-fish-config
garuda-gamer
garuda-hooks
garuda-hotfixes
garuda-icons
garuda-network-assistant
garuda-settings-manager
garuda-setup-assistant
garuda-system-maintenance
garuda-video-linux-config
garuda-wallpapers
garuda-welcome
garuda-zsh-config
geany
gnome-disk-utility
gnome-system-monitor
gparted
gptfdisk
grimblast-git
grimshot
grub-btrfs
grub-garuda
grub-theme-garuda
gwenview
gzip
htop
hyprland
hyprpaper
inkscape
input-remapper-git
kate
kde-cli-tools
kdeconnect
kitty
kvantum
lazygit
libsixel
linux-firmware
linux-zen
linux-zen-headers
lolcat
lutris
mangohud
megatools
meld
micro
mkvtoolnix-gui
mousepad
mpv
mpv-mpris
ncdu
neovim
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
nvme-cli
nvtop
nwg-look
obsidian
octopi
openrgb
opensnitch
opensnitch-ebpf-module
os-prober-btrfs
otf-font-awesome
otf-font-awesome-4
p7zip
p7zip-gui
pamixer
paru
pavucontrol
pipewire-jack
pipewire-support
plasma-systemmonitor
pokemon-colorscripts-git
polkit-gnome
powertop
protonup-qt
protonvpn-gui
python-pip
python-pywal
qt5-styleplugins
qt5ct
qt6ct
radeon-profile-daemon-git
radeon-profile-git
radeontool
radeontop
ranger
rate-mirrors
reflector-simple
rofi-lbonn-wayland-git
rsync
screenkey
sddm
smartmontools
snapper-support
snapper-tools
speedtest-cli
steam
stow
subliminal-git
subversion
swappy
swayidle
swaylock-effects
swaync
swww
thunar
thunar-archive-plugin
thunar-volman
thunderbird
ttf-dejavu
ttf-droid
ttf-fantasque-sans-mono
ttf-fira-sans
ttf-firacode-nerd
ttf-font-awesome
ttf-font-awesome-4
ttf-jetbrains-mono
ttf-jetbrains-mono-nerd
ttf-nerd-fonts-symbols-mono
ttf-opensans
ttf-ubuntu-font-family
tty-clock
ufw
upscayl-bin
vscodium
waybar
waybar-module-pacman-updates-git
wev
wine-staging
wl-clipboard
wlsunset
xbox-generic-controller
xdg-desktop-portal
xdg-desktop-portal-hyprland
xsel
yakuake
yt-dlp-drop-in
fzf
zoxide
xwaylandvideobridge
hyprlock
hypridle
hyprpicker
kvantum-qt5
ark
chafa
dart-sass
 archlinux-xdg-menu
goverlay
wallust
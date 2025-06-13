
<h1 align="center">
  <br>
  <img src="https://github.com/sergoncano/hollow-knight-grub-theme/blob/master/resources/pageLogo.png" alt="Happy GRUB" width="200">
  <br>
  Hollow GRUB
  <br>
</h1>

<h4 align="center">A theme for the bootloader GRUB based off hollow knight's main menu.</h4>

<p align="center">
  <a href="#installation">Installation</a> •
  <a href="#customization">Customization</a> •
  <a href="#credits">Credits</a>
</p>

![screenshot](https://github.com/sergoncano/hollow-knight-grub-theme/blob/master/resources/Showcase.gif)
## Installation
Install the files:
```bash
# Clone this repository
$ git clone https://github.com/sergoncano/hollow-knight-grub-theme.git

# Go into the repository
$ cd hollow-knight-grub-theme

# Make the installer executable
$ chmod +x install_theme.sh

# Run the installer
$ sudo ./install_theme.sh
```
Now set the theme in your grub config (```/etc/default/grub```) by adding (or modifying) the following line:
```bash
GRUB_THEME="/boot/grub/themes/hollow-grub/theme.txt"
```
Finally reload the GRUB config:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```
## Customization
If you want to add a new background (the day silksong comes out), just put it in the ```wallpapers/``` directory. After that, run the install script again and choose it when prompted for.
## Credits
All the art used here belongs to the game <a href="https://www.hollowknight.com/" target="_blank">Hollow Knight</a>.<br>
The installation script is a variation of <a href="https://github.com/Lxtharia/minegrub-theme" target="_blank">minegrub</a>'s. 


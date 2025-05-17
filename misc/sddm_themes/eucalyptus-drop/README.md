# Readme

Eucalyptus Drop is an enhanced fork of SDDM Sugar Candy by Marian Arlt.

This theme focuses on a straightforward user experience and superb functionality while offering a great degree of customisation.

![Out-of-the-box configuration](Previews/sddm-eucalyptus-drop.png)

Eucalyptus Drop should work on any SDDM installation / Linux distribution, provided dependencies are met.

All controls use the [latest Qt Quick Controls 2](http://doc.qt.io/qt-5/qtquickcontrols2-index.html) for [increased performance](https://blog.qt.io/blog/2015/03/31/qt-quick-controls-for-embedded/) even on low-end or embedded systems.

## Installation

### From within KDE Plasma

If you are on [KDE Plasma](https://www.kde.org/plasma-desktop)—by default [Manjaro](https://manjaro.org/), [OpenSuse](https://www.opensuse.org/), [Neon](https://neon.kde.org/), [Kubuntu](https://kubuntu.org/), [KaOS](https://kaosx.us/) or [Chakra](https://www.chakralinux.org/) for example—you are lucky and can simply go to your system settings and under "Startup and Shutdown" **→** "Login Screen (SDDM)" click "Get New Theme". From there search for "Eucalyptus Drop" and install.

If for some reason you cannot find the category named "Login Screen (SDDM)" in your system settings then you are missing the module `sddm-kcm`. Install this with your package manager first.

### From other desktop environments

Download the latest release zip and extract the contents to the theme directory of SDDM:

`$ sddmthemeinstaller --install sddm-eucalyptus-drop-v1.0.1.zip`

This will extract all the files to a folder called "eucalyptus-drop" inside of the themes directory of SDDM.

After that you will have to point SDDM to the new theme by editing its config file, preferrably at `/etc/sddm.conf.d/sddm.conf` *(create if necessary)*. You can take the default config file of SDDM as a reference which might be found at: `/usr/lib/sddm/sddm.conf.d/sddm.conf`.

In the `[Theme]` section simply add the themes name to this line: `Current=eucalyptus-drop`. If you don't care for SDDM options and you had to create the file from scratch, just add those two lines and save it:

```conf
[Theme]
Current=eucalyptus-drop
```

## Dependencies

- [SDDM  >= 0.18](https://github.com/sddm/sddm)
- [Qt5 >= 5.11](https://doc.qt.io/archives/qt-5.11/index.html) including:
  - [`Qt Graphical Effects`](https://doc.qt.io/archives/qt-5.11/qtgraphicaleffects-index.html)
  - [`Qt Quick Controls 2`](https://doc.qt.io/archives/qt-5.11/qtquickcontrols2-index.html)
  - [`Qt Quick Layouts`](https://doc.qt.io/archives/qt-5.11/qtquicklayouts-index.html)
  - [`Qt Quick Window`](https://doc.qt.io/qt-5.11/qml-qtquick-window-screen.html)
  - [`Qt SVG`](https://doc.qt.io/archives/qt-5.11/qtsvg-index.html)

*Make sure these are installed with their required version or higher! SDDM might need an enabled system service/daemon to work. This is often done automatically during installation. Take note that a lot of standard release distros like Debian, Mint, MX, Elementary, Deepin or Ubuntu LTS are still on earlier versions. If in doubt ask in your distros forums.*

**Debian based** distros using the **APT** package manager:
*(Ubuntu/Kubuntu/Kali/Neon/antiX etc.)*
`sudo apt install --no-install-recommends sddm qml‑module‑qtquick‑layouts qml‑module‑qtgraphicaleffects qml‑module‑qtquick‑controls2 libqt5svg5`

**Arch based** distros using the **pacman** package manger:
*(Obarun/Artix/Manjaro/KaOS/Chakra etc.)*
`sudo pacman -S --needed sddm qt5‑graphicaleffects qt5‑quickcontrols2 qt5‑svgz`

**openSUSE** using the **zypper** package manager:
`sudo zypper install sddm libqt5‑qtgraphicaleffects libqt5‑qtquickcontrols2 libQt5Svg5 libQt5Svg5`

**Red Hat** based distros using the **dnf** package manager:
*(Fedora/Mageia/RHEL/CentOS)*
`sudo dnf install sddm qt5‑qtgraphicaleffects qt5‑qtquickcontrols2 qt5‑qtsvg`

## Configuration

You can customise Eucalyptus Drop by editing its `theme.conf`. You can change the colours and images used, the time and date formats, the appearance of the whole interface and even how it works.

It's annoying to log out and back in every time you want to see a change made to your `theme.conf`. To preview your changes from within your running desktop environment session simply run:
`sddm-greeter --test-mode --theme /usr/share/sddm/themes/eucalyptus-drop`

And as if that wouldn't still be enough you can **translate every single button and label** because SDDM still [needs your help](https://github.com/sddm/sddm/wiki/Localization) to make localisation as complete as possible!

|            **Option**            |         **Default**          |                                                                                                                                                                **Description**                                                                                                                                                                 |
| -------------------------------- |:----------------------------:| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Background`                     | `"Backgrounds/Mountain.jpg"` | Path relative to the theme root directory. Most standard image file formats are allowed including support for transparency.                                                                                                                                                                                                                    |
| `DimBackgroundImage`             | `"0.0"`                      | Double between 0 and 1 used for the alpha channel of a darkening overlay. Use to darken your background image on the fly.                                                                                                                                                                                                                      |
| `ScaleImageCropped`              | `"true"`                     | Whether the image should be cropped when scaled proportionally. Setting this to false will fit the whole image instead, possibly leaving white space. This can be exploited beautifully with illustrations.                                                                                                                                    |
| `ScreenWidth`                    | `"2560"`                     | Set to your resolution to help SDDM speed up on calculations.                                                                                                                                                                                                                                                                                  |
| `ScreenHeight`                   | `"1440"`                     | Set to your resolution to help SDDM speed up on calculations.                                                                                                                                                                                                                                                                                  |
| `FullBlur`                       | `"false"`                    | Enable or disable the blur effect                                                                                                                                                                                                                                                                                                              |
| `PartialBlur`                    | `"false"`                    | Enable or disable the blur effect; if HaveFormBackground is set to true then PartialBlur will trigger the BackgroundColour of the form element to be partially transparent and blend with the blur.                                                                                                                                            |
| `BlurRadius`                     | `"100"`                      | Set the strength of the blur effect. Anything above 100 is pretty strong and might slow down the rendering time. 0 is like setting false for any blur.                                                                                                                                                                                         |
| `HaveFormBackground`             | `"false"`                    | Have a full opacity background colour behind the form that takes slightly more than 1/3 of screen estate;  if PartialBlur is set to true then HaveFormBackground will trigger the BackgroundColour of the form element to be partially transparent and blend with the blur.                                                                    |
| `FormPosition`                   | `"center"`                   | Position of the form which takes roughly 1/3 of screen estate. Can be left, center or right.                                                                                                                                                                                                                                                   |
| `BackgroundImageHAlignment`      | `"center"`                   | Horizontal position of the background picture relative to its visible area. Applies when ScaleImageCropped is set to false or when HaveFormBackground is set to true and FormPosition is either left or right. Can be left, center or right; defaults to center if none is passed.                                                             |
| `BackgroundImageVAlignment`      | `"center"`                   | As before but for the vertical position of the background picture relative to its visible area.                                                                                                                                                                                                                                                |
| `MainColour`                     | `"white"`                    | Used for all elements when not focused/hovered etc. Usually the best effect is achieved by having this be either white or a very dark grey like #444 (not black for smoother antialias). Colours can be HEX or Qt names (e.g. red/salmon/blanchedalmond). See [https://doc.qt.io/qt-5/qml-colour.html](https://doc.qt.io/qt-5/qml-colour.html) |
| `AccentColour`                   | `"#fb884f"`                  | Used for elements in focus/hover/pressed. Should be contrasting to the background and the MainColour to achieve the best effect.                                                                                                                                                                                                               |
| `BackgroundColour`               | `"#444"`                     | Used for the user and session selection background as well as for ScreenPadding and FormBackground when either is true. If PartialBlur and FormBackground are both enabled this colour will blend with the blur effect.                                                                                                                        |
| `OverrideLoginButtonTextColour`  | `""`                         | The text of the login button may become difficult to read depending on your colour choices. Use this option to set it independently for legibility.                                                                                                                                                                                            |
| `InterfaceShadowSize`            | `"6"`                        | Integer used as multiplier. Size of the shadow behind the user and session selection background. Decrease or increase if it looks bad on your background. Initial render can be slow for values above 5-7.                                                                                                                                     |
| `InterfaceShadowOpacity`         | `"0.6"`                      | Double between 0 and 1. Alpha channel of the shadow behind the user and session selection background. Decrease or increase if it looks bad on your background.                                                                                                                                                                                 |
| `RoundCorners`                   | `"20"`                       | Integer in pixels. Radius of the input fields and the login button. Empty for square. Can cause bad antialiasing of the fields.                                                                                                                                                                                                                |
| `ScreenPadding`                  | `"0"`                        | Integer in pixels. Increase or delete this to have a padding of colour BackgroundColour all around your screen. This makes your login greeter appear as if it was a canvas. Cool!                                                                                                                                                              |
| `Font`                           | `"Noto Sans"`                | If you want to choose a custom font it will have to be available to the X root user. See https://wiki.archlinux.org/index.php/fonts#Manual_installation                                                                                                                                                                                        |
| `FontSize`                       | `""`                         | Only set a fixed value if fonts are way too small for your resolution. Preferrably kept empty.                                                                                                                                                                                                                                                 |
| `ForceRightToLeft`               | `"false"`                    | Revert the layout either because you would like the login to be on the right hand side or SDDM won't respect your language locale for some reason.                                                                                                                                                                                             |
| `ForceLastUser`                  | `"true"`                     | Have the last successfully logged in user appear automatically in the username field.                                                                                                                                                                                                                                                          |
| `ForcePasswordFocus`             | `"true"`                     | Give automatic focus to the password field. Together with ForceLastUser this makes for the fastest login experience.                                                                                                                                                                                                                           |
| `ForceHideCompletePassword`      | `"false"`                    | If you don't want password characters to be displayed (even briefly) set this to true.                                                                                                                                                                                                                                                   |
| `ForceHideVirtualKeyboardButton` | `"false"`                    | Do not show the button for the virtual keyboard at all. This will completely disable functionality for the virtual keyboard even if it is installed and activated in sddm.conf                                                                                                                                                                 |
| `ForceHideSystemButtons`         | `"false"`                    | Completely disable and hide any power buttons on the greeter.                                                                                                                                                                                                                                                                                  |
| `AllowEmptyPassword`             | `"false"`                    | Enable login for users without a password. This is discouraged. Makes the login button always enabled.                                                                                                                                                                                                                                         |
| `AllowBadUsernames`              | `"false"`                    | Do not change this! Uppercase letters are generally not allowed in usernames. This option is only for systems that differ from this standard! Also shows username as is instead of capitalized.                                                                                                                                                |
| `Locale`                         | `""`                         | The time and date locale should usually be set in your system settings. Only hard set this if something is not working by default or you want a seperate locale setting in your login screen.                                                                                                                                                  |
| `HourFormat`                     | `"HH:mm"`                    | Defaults to Locale.ShortFormat - Accepts "long" or a custom string like "hh:mm A". See http://doc.qt.io/qt-5/qml-qtqml-date.html                                                                                                                                                                                                               |
| `DateFormat`                     | `"dddd, d of MMMM"`          | Defaults to Locale.LongFormat - Accepts "short" or a custom string like "dddd, d 'of' MMMM". See http://doc.qt.io/qt-5/qml-qtqml-date.html                                                                                                                                                                                                     |
| `HeaderText`                     | `"Welcome!"`                 | Header can be empty to not display any greeting at all. Keep it short.                                                                                                                                                                                                                                                                         |

### Localisation

SDDM may lack proper translation for every element; the theme defaults to SDDM translations.

Please help translate SDDM into your language: https://github.com/sddm/sddm/wiki/Localization.

You may use the configuration items below to override a bad translation.

`TranslatePlaceholderUsername`
`TranslatePlaceholderPassword`
`TranslateShowPassword`
`TranslateLogin`
`TranslateLoginFailedWarning`
`TranslateCapslockWarning`
`TranslateSession`
`TranslateSuspend`
`TranslateHibernate`
`TranslateReboot`
`TranslateShutdown`
`TranslateVirtualKeyboardButton`

These don't necessarily need to translate anything. You can use these fields to substitute the text with whatever you want.

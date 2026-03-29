#!/bin/bash

src_file="$HOME/.cache/hellwal/qt_dolphin_colors.colors"
[ -f "$src_file" ] && cp -f "$src_file" "$HOME/.local/share/color-schemes/CatppuccinMochaColorAdapt.colors"

plasma-apply-colorscheme CatppuccinMochaFlamingo
plasma-apply-colorscheme CatppuccinMochaColorAdapt

gdbus emit --session \
  --object-path /org/freedesktop/portal/desktop \
  --signal org.freedesktop.portal.Settings.SettingChanged \
  "org.kde.kdeglobals.General" "ColorScheme" "<'CatppuccinMochaColorAdapt'>"

DBUS=$(qdbus | grep org.kde.dolphin | head -1 | tr -d ' ')
NEW_COLOR=$(grep "^highlight.color" ~/.config/Kvantum/Catppuccin-Mocha-Mauve-pywal/Catppuccin-Mocha-Mauve-pywal.kvconfig | cut -d= -f2)

if [ -n "$DBUS" ] && [ -n "$NEW_COLOR" ]; then
    qdbus "$DBUS" /MainApplication org.qtproject.Qt.QApplication.setStyleSheet "* {}"
    sleep 0.1

    qdbus "$DBUS" /MainApplication org.qtproject.Qt.QApplication.setStyleSheet "
QWidget { color: palette(text); background: palette(window); }
QAbstractItemView { selection-background-color: ${NEW_COLOR}; }
QAbstractItemView::item:selected { background-color: ${NEW_COLOR}; color: #181825; }
QAbstractItemView::item:selected:active { background-color: ${NEW_COLOR}; color: #181825; }
QAbstractItemView::item:selected:!active { background-color: ${NEW_COLOR}; color: #181825; }
QTreeView::item:selected { background-color: ${NEW_COLOR}; color: #181825; }
QListView::item:selected { background-color: ${NEW_COLOR}; color: #181825; }
QListWidget::item:selected { background-color: ${NEW_COLOR}; color: #181825; }
QListWidget::item:selected:active { background-color: ${NEW_COLOR}; color: #181825; }
KFilePlacesView::item:selected { background-color: ${NEW_COLOR}; color: #181825; }
QProgressBar::chunk { background-color: ${NEW_COLOR}; }
QRubberBand { background-color: ${NEW_COLOR}; border: 1px solid ${NEW_COLOR}; }
QToolButton:checked { background-color: ${NEW_COLOR}; color: #181825; border-radius: 4px; }
QToolBar QToolButton:checked { background-color: ${NEW_COLOR}; color: #181825; border-radius: 4px; }
QAbstractButton:checked { background-color: ${NEW_COLOR}; color: #181825; }
"
fi
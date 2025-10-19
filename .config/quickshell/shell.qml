//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import "./modules/common/"
import "./modules/overview/"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "./services/"

ShellRoot {
    property bool enableOverview: true
    property bool enablePalette: true

    Component.onCompleted: {
        // Comment out missing singletons temporarily
        // MaterialThemeLoader.reapplyTheme()
        // ConfigLoader.loadConfig()
    }

    Loader { active: enableOverview; sourceComponent: Overview {} }
    //Loader { active: enablePalette; source: "./PaletteWidget.qml" }
}
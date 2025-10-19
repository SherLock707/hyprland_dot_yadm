//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import "./modules/common/"
import "./modules/overview/"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "./services/"

ShellRoot {
    property bool enableOverview: true
    property bool enablePalette: true

    Component.onCompleted: {
        // Load configuration from config.json
        ConfigLoader.loadConfig()
        // Load material theme colors
        MaterialThemeLoader.reapplyTheme()
    }

    Loader { active: enableOverview; sourceComponent: Overview {} }
    Loader { active: enablePalette; source: "./PaletteWidget.qml" }
    
    // Always load the palette IpcHandler even if widget is disabled
    IpcHandler {
        target: "palette"
        
        function toggle() {
            console.log("Palette toggle called from shell")
            GlobalStates.paletteOpen = !GlobalStates.paletteOpen
        }
        function close() {
            console.log("Palette close called from shell")
            GlobalStates.paletteOpen = false
        }
        function open() {
            console.log("Palette open called from shell")
            GlobalStates.paletteOpen = true
        }
    }
}
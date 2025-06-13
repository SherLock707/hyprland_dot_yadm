import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
    // Process to read home directory
    Process {
        id: homeProcess
        command: ["sh", "-c", "echo $HOME"]
        Component.onCompleted: start()
        
        property string userHome: ""
        
        onExited: {
            userHome = stdout.trim()
            colorLoader.loadColors()
        }
    }
    
    // Process for loading colors
    Process {
        id: colorLoader
        
        property string colorJsonPath: homeProcess.userHome + "/.cache/hellwal/colors.json"
        
        onExited: {
            if (exitCode === 0) {
                try {
                    let parsedColors = JSON.parse(stdout)
                    colorManager.colors = parsedColors
                    colorManager.colorKeys = Object.keys(parsedColors)
                    console.log("Loaded", colorManager.colorKeys.length, "colors")
                } catch (e) {
                    console.error("Failed to parse colors:", e)
                }
            } else {
                console.error("Failed to load colors file")
            }
        }
        
        function loadColors() {
            if (homeProcess.userHome !== "") {
                command = ["cat", colorJsonPath]
                start()
            }
        }
    }
    
    // Color picker process
    Process {
        id: colorPicker
        
        property string targetLabel: ""
        
        onExited: {
            if (exitCode === 0 && stdout.trim()) {
                let newColor = stdout.trim()
                if (newColor.startsWith('#') && targetLabel !== "") {
                    colorManager.updateColor(targetLabel, newColor)
                }
            }
        }
        
        function pickColor(label, currentColor) {
            targetLabel = label
            command = ["kcolorchooser", "--color=" + currentColor, "--print"]
            start()
        }
    }
    
    // Clipboard copy process
    Process {
        id: clipboardProcess
        
        function copyToClipboard(text) {
            command = ["sh", "-c", "echo -n '" + text + "' | xclip -selection clipboard"]
            start()
        }
    }
    
    // Theme writer process
    Process {
        id: themeWriter
        
        property string themePath: homeProcess.userHome + "/.config/hellwal/themes/custom.hellwal"
        
        function writeTheme() {
            let themeContent = ""
            for (let key in colorManager.colors) {
                themeContent += "%% " + key + "  = " + colorManager.colors[key] + " %%\\n"
            }
            
            command = ["sh", "-c", "printf '" + themeContent + "' > '" + themePath + "'"]
            start()
        }
        
        onExited: {
            if (exitCode === 0) {
                scriptRunner.refreshTheme()
            }
        }
    }
    
    // Script runner process
    Process {
        id: scriptRunner
        
        property string scriptPath: homeProcess.userHome + "/.config/hypr/scripts/PywalSwww.sh"
        
        function refreshTheme() {
            command = ["sh", "-c", "test -f '" + themeWriter.themePath + "' && '" + scriptPath + "' theme-only"]
            start()
        }
    }
    
    PanelWindow {
        id: paletteWindow
        
        anchor {
            left: true
            top: true
        }
        
        margins {
            left: 350
            top: 10
        }
        
        layer: ShellLayer.Overlay
        keyboardFocus: ShellKeyboardFocus.OnDemand
        focusable: true
        
        width: 440
        height: mainContent.implicitHeight + 20
        
        color: "transparent"
        
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                paletteWindow.setVisible(false)
            }
        }
        
        Rectangle {
            id: mainContent
            anchors.fill: parent
            anchors.margins: 10
            
            color: Qt.rgba(0.12, 0.12, 0.18, 0.7)
            border.width: 2
            border.color: colorManager.getColor("color7", "#ffffff")
            radius: 20
            
            // Bottom border effect
            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 2
                }
                height: 4.5
                color: parent.border.color
                radius: parent.radius
            }
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 8
                
                // Wallpaper preview
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 225
                    color: "#2a2a2a"
                    radius: 10
                    clip: true
                    
                    Image {
                        anchors.fill: parent
                        source: "file://" + homeProcess.userHome + "/.config/rofi/.current_wallpaper"
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.1)
                            radius: parent.parent.radius
                        }
                    }
                }
                
                // Color palette
                Repeater {
                    model: colorManager.colorKeys
                    
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        color: "transparent"
                        
                        RowLayout {
                            anchors.fill: parent
                            spacing: 8
                            
                            // Copy button
                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                color: mouseArea1.containsMouse ? "#555" : "#444"
                                radius: 6
                                border.width: 1
                                border.color: Qt.rgba(1, 1, 1, 0.1)
                                
                                Behavior on color { ColorAnimation { duration: 150 } }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰆏"
                                    color: "#ffffff"
                                    font.pixelSize: 14
                                }
                                
                                MouseArea {
                                    id: mouseArea1
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        let colorValue = colorManager.getColor(modelData)
                                        if (colorValue) {
                                            clipboardProcess.copyToClipboard(colorValue)
                                            console.log("Copied", modelData, ":", colorValue)
                                        }
                                    }
                                }
                            }
                            
                            // Color display button
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                
                                property string colorValue: colorManager.getColor(modelData, "#888888")
                                
                                color: colorValue
                                radius: 6
                                border.width: 1
                                border.color: Qt.rgba(0, 0, 0, 0.2)
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: colorManager.getComplementaryColor(parent.colorValue)
                                    font.bold: true
                                    font.pixelSize: 12
                                }
                            }
                            
                            // Edit button
                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                color: mouseArea2.containsMouse ? "#555" : "#444"
                                radius: 6
                                border.width: 1
                                border.color: Qt.rgba(1, 1, 1, 0.1)
                                
                                Behavior on color { ColorAnimation { duration: 150 } }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    color: "#ffffff"
                                    font.pixelSize: 14
                                }
                                
                                MouseArea {
                                    id: mouseArea2
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        let currentColor = colorManager.getColor(modelData, "#ffffff")
                                        colorPicker.pickColor(modelData, currentColor)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Refresh button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    Layout.topMargin: 8
                    color: mouseArea3.containsMouse ? "#555" : "#444"
                    radius: 8
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.2)
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Text {
                        anchors.centerIn: parent
                        text: " Refresh Theme"
                        color: "#ffffff"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    MouseArea {
                        id: mouseArea3
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            console.log("Refreshing theme...")
                            themeWriter.writeTheme()
                        }
                    }
                }
            }
        }
    }
    
    // Color management
    QtObject {
        id: colorManager
        
        property var colors: ({})
        property var colorKeys: []
        property var complementaryCache: ({})
        
        function getColor(key, defaultValue) {
            return colors[key] || defaultValue || "#ffffff"
        }
        
        function updateColor(key, newColor) {
            colors[key] = newColor
            // Force property binding updates
            let temp = colors
            colors = {}
            colors = temp
        }
        
        function getComplementaryColor(hexColor) {
            if (!hexColor) return "#ffffff"
            
            if (complementaryCache[hexColor]) {
                return complementaryCache[hexColor]
            }
            
            let color = hexColor.replace('#', '')
            if (color.length !== 6) {
                return '#ffffff'
            }
            
            try {
                let r = parseInt(color.substr(0, 2), 16)
                let g = parseInt(color.substr(2, 2), 16)
                let b = parseInt(color.substr(4, 2), 16)
                
                let brightness = 0.299 * r + 0.587 * g + 0.114 * b
                let result = brightness > 186 ? '#000000' : '#ffffff'
                
                complementaryCache[hexColor] = result
                return result
            } catch (e) {
                return '#ffffff'
            }
        }
    }
}
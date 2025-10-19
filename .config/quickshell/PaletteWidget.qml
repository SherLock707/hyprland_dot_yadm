import "root:/"
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: paletteWindow
    
    property var colorDict: ({})
    property var colorKeys: Object.keys(colorDict)
    property string themePath: `${Quickshell.env("HOME")}/.config/hellwal/themes/custom.hellwal`
    property string wallpaperPath: `${Quickshell.env("HOME")}/.config/rofi/.current_wallpaper`
    property string scriptPath: `${Quickshell.env("HOME")}/.config/hypr/scripts/ThemeEngine.sh`
    property string colorJsonPath: `${Quickshell.env("HOME")}/.cache/hellwal/colors.json`
    
    anchors {
        top: true
        left: true
    }
    
    margins {
        top: 10
        left: 350
    }
    
    implicitWidth: mainContainer.implicitWidth
    implicitHeight: mainContainer.implicitHeight
    
    color: "transparent"
    mask: Region { item: mainContainer }
    visible: GlobalStates.paletteOpen
    
    WlrLayershell.namespace: "quickshell:palette"
    WlrLayershell.layer: WlrLayer.Overlay
    
    // Focus handling using HyprlandFocusGrab
    HyprlandFocusGrab {
        id: focusGrab
        windows: [paletteWindow]
        active: GlobalStates.paletteOpen
        onCleared: () => {
            if (!active) GlobalStates.paletteOpen = false
        }
    }
    
    // Global shortcut for Escape key
    GlobalShortcut {
        name: "paletteClose"
        description: qsTr("Closes palette")
        
        onPressed: {
            GlobalStates.paletteOpen = false
        }
    }
    
    Process {
        id: colorLoader
        command: ["cat", colorJsonPath]
        running: true
        
        property bool loaded: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                if (!colorLoader.loaded) {
                    colorLoader.loaded = true
                    try {
                        const content = text.trim()
                        if (content) {
                            console.log("Loaded colors from:", colorJsonPath)
                            console.log("Raw content:", content)
                            colorDict = JSON.parse(content)
                            colorKeys = Object.keys(colorDict)
                            console.log("Parsed colorDict:", colorDict)
                            console.log("Color keys:", colorKeys)
                        } else {
                            console.log("Empty output from cat command")
                            // Fallback to default colors if file is empty
                            colorDict = {
                                "color0": "#1e1e2e",
                                "color1": "#f38ba8", 
                                "color2": "#a6e3a1",
                                "color3": "#f9e2af",
                                "color4": "#89b4fa",
                                "color5": "#cba6f7",
                                "color6": "#94e2d5",
                                "color7": "#cdd6f4"
                            }
                            colorKeys = Object.keys(colorDict)
                        }
                    } catch (e) {
                        console.log("Failed to parse colors.json:", e)
                        console.log("Content that failed to parse:", text)
                        // Fallback to default colors if parsing fails
                        colorDict = {
                            "color0": "#1e1e2e",
                            "color1": "#f38ba8", 
                            "color2": "#a6e3a1",
                            "color3": "#f9e2af",
                            "color4": "#89b4fa",
                            "color5": "#cba6f7",
                            "color6": "#94e2d5",
                            "color7": "#cdd6f4"
                        }
                        colorKeys = Object.keys(colorDict)
                    }
                }
            }
        }
        
        onExited: function(exitCode) {
            if (exitCode !== 0 && !loaded) {
                console.log("Failed to read color file, using defaults")
                loaded = true
                // Fallback to default colors if file doesn't exist
                colorDict = {
                    "color0": "#1e1e2e",
                    "color1": "#f38ba8", 
                    "color2": "#a6e3a1",
                    "color3": "#f9e2af",
                    "color4": "#89b4fa",
                    "color5": "#cba6f7",
                    "color6": "#94e2d5",
                    "color7": "#cdd6f4"
                }
                colorKeys = Object.keys(colorDict)
            }
        }
    }
    
    // Calculate complementary color for text (matches Python version)
    function complementaryColor(hexColor) {
        hexColor = hexColor.replace('#', '')
        if (hexColor.length !== 6) return '#ffffff'
        
        const r = parseInt(hexColor.substr(0, 2), 16)
        const g = parseInt(hexColor.substr(2, 2), 16)
        const b = parseInt(hexColor.substr(4, 2), 16)
        
        const brightness = 0.299 * r + 0.587 * g + 0.114 * b
        return brightness > 186 ? '#000000' : '#ffffff'
    }
    
    // Write theme file
    function writeTheme() {
        let content = ""
        for (const key in colorDict) {
            content += `%% ${key}  = ${colorDict[key]} %%\n`
        }
        
        const processComp = Qt.createQmlObject('import Quickshell.Io; Process {}', paletteWindow)
        processComp.command = ["sh", "-c", `echo '${content}' > ${themePath}`]
        processComp.running = true
    }
    
    // Refresh theme
    function refreshTheme() {
        console.log("Refreshing theme...")
        writeTheme()
        
        const processComp = Qt.createQmlObject('import Quickshell.Io; Process {}', paletteWindow)
        processComp.command = [scriptPath, "theme-only"]
        processComp.running = true
    }
    
    // Pick color using kcolorchooser
    function pickColor(label, currentColor) {
        const processComp = Qt.createQmlObject('import Quickshell.Io; Process {}', paletteWindow)
        processComp.command = ["kcolorchooser", "--color=" + currentColor, "--print"]
        
        processComp.stdout = Qt.createQmlObject('import Quickshell.Io; StdioCollector {}', processComp)
        processComp.stdout.onStreamFinished.connect(function() {
            const newColor = processComp.stdout.text.trim()
            console.log("Color picker output:", newColor)
            if (newColor && newColor.startsWith('#')) {
                colorDict[label] = newColor
                // Trigger reactivity by creating new object
                colorDict = Object.assign({}, colorDict)
                colorKeys = Object.keys(colorDict)
                console.log("Updated color for", label, "to", newColor)
            }
        })
        
        processComp.running = true
    }
    
    // Copy to clipboard
    function copyToClipboard(text) {
        const processComp = Qt.createQmlObject('import Quickshell.Io; Process {}', paletteWindow)
        processComp.command = ["wl-copy", text]
        processComp.running = true
    }
    
    Rectangle {
        id: mainContainer
        implicitWidth: contentColumn.implicitWidth + 20
        implicitHeight: contentColumn.implicitHeight + 20
        color: Qt.rgba(0.118, 0.118, 0.180, 0.7) // #1e1e2e with 0.7 alpha
        radius: 20
        border.width: 2
        border.color: colorDict["color7"] || "#ffffff"
        
        ColumnLayout {
            id: contentColumn
            anchors {
                fill: parent
                margins: 10
            }
            spacing: 5
            
                // Wallpaper image - dynamic sizing
                Rectangle {
                    Layout.preferredWidth: 400
                    Layout.preferredHeight: wallpaperImage.status === Image.Ready ? Math.min(400 / wallpaperImage.implicitWidth * wallpaperImage.implicitHeight, 300) : 225
                    Layout.alignment: Qt.AlignHCenter
                    radius: 8
                    color: "transparent"
                
                Rectangle {
                    id: imageContainer
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: parent.radius - 1
                    color: "transparent"
                    
                    // Clip the image to the rounded rectangle
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: imageContainer.width
                            height: imageContainer.height
                            radius: imageContainer.radius
                        }
                    }
                    
                        Image {
                            id: wallpaperImage
                            anchors.fill: parent
                            source: "file://" + wallpaperPath
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            visible: status === Image.Ready
                        
                        onStatusChanged: {
                            console.log("Image status:", status)
                            console.log("Image source:", source)
                            if (status === Image.Error) {
                                console.log("Failed to load wallpaper from:", wallpaperPath)
                                console.log("Checking if file exists...")
                                // Try to check if file exists
                                const checkProcess = Qt.createQmlObject('import Quickshell.Io; Process {}', paletteWindow)
                                checkProcess.command = ["test", "-f", wallpaperPath]
                                checkProcess.onExited.connect(function(exitCode) {
                                    if (exitCode === 0) {
                                        console.log("File exists but failed to load - might be corrupted or wrong format")
                                    } else {
                                        console.log("File does not exist at:", wallpaperPath)
                                    }
                                })
                                checkProcess.running = true
                            } else if (status === Image.Ready) {
                                console.log("Wallpaper loaded successfully")
                            }
                        }
                    }
                }
                
                // Placeholder text when image fails to load
                Text {
                    anchors.centerIn: parent
                    text: "No Wallpaper"
                    color: colorDict["foreground"] || "#ffffff"
                    font.pixelSize: 16
                    visible: wallpaperImage.status === Image.Error || wallpaperImage.status === Image.Null
                }
            }
            
            // Color rows
            Repeater {
                model: colorKeys
                
                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    property string colorLabel: modelData
                    property string colorValue: colorDict[colorLabel] || "#000000"
                    
                        // Copy button - minimal width
                        Button {
                            Layout.minimumWidth: 40
                            Layout.preferredHeight: 35
                            text: "󰆏"
                            
                            onClicked: copyToClipboard(colorValue)
                            
                            background: Rectangle {
                                color: parent.pressed ? Qt.color(colorDict["color7"] || "#ffffff").alpha(0.3) : Qt.color(colorDict["color7"] || "#ffffff").alpha(0.2)
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    
                    // Color display button - expands
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        text: colorLabel
                        
                        background: Rectangle {
                            color: colorValue
                            radius: 8
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: complementaryColor(colorValue)
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                        // Edit button - minimal width
                        Button {
                            Layout.minimumWidth: 40
                            Layout.preferredHeight: 35
                            text: "󰏫"
                            
                            onClicked: pickColor(colorLabel, colorValue)
                            
                            background: Rectangle {
                                color: parent.pressed ? Qt.color(colorDict["color7"] || "#ffffff").alpha(0.3) : Qt.color(colorDict["color7"] || "#ffffff").alpha(0.2)
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                }
            }
            
            // Refresh button
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: ""
                
                onClicked: refreshTheme()
                
                background: Rectangle {
                    color: parent.pressed ? Qt.color(colorDict["color7"] || "#ffffff").alpha(0.3) : Qt.color(colorDict["color7"] || "#ffffff").alpha(0.2)
                    radius: 8
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    
    
    
    Component.onCompleted: {
        console.log("PaletteWidget loaded")
        console.log("Wallpaper path:", wallpaperPath)
        console.log("Color JSON path:", colorJsonPath)
        console.log("Theme path:", themePath)
        console.log("Script path:", scriptPath)
    }
}
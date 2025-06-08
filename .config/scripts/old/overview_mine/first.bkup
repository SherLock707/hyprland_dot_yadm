import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    id: shell
    
    // Workspace drop zone component
    component WorkspaceDropZone: Rectangle {
        id: dropZone
        
        property var workspaceData
        property var clients: []
        property bool active: false
        property var monitor
        property var overviewRef
        property bool dragHover: false
        
        color: "transparent"
        
        // Styling based on state
        property string backgroundImage: "file://" + Quickshell.env("HOME") + "/.config/rofi/.current_wallpaper"
        
        Rectangle {
            anchors.fill: parent
            anchors.margins: 3
            radius: 6
            
            // Background image (simulated with color for now)
            color: dropZone.active ? "#4a5568" : "#2d3748"
            
            border.width: {
                if (dropZone.dragHover) {
                    return dropZone.active ? 6 : 3
                }
                return dropZone.active ? 3 : 1
            }
            
            border.color: {
                if (dropZone.dragHover) {
                    return dropZone.active ? "#63b3ed" : "#4299e1"
                }
                return dropZone.active ? "#7c7c7c" : "#4a5568"
            }
            
            // Drop area
            DropArea {
                anchors.fill: parent
                keys: ["window-address"]
                
                onEntered: {
                    dropZone.dragHover = true
                }
                
                onExited: {
                    dropZone.dragHover = false
                }
                
                onDropped: function(drop) {
                    let windowAddress = drop.getDataAsString("window-address")
                    if (windowAddress) {
                        Hyprland.dispatch("movetoworkspacesilent", 
                                           dropZone.workspaceData.id + ",address:" + windowAddress)
                    }
                    dropZone.dragHover = false
                }
            }
            
            // Click to switch workspace
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Hyprland.dispatch("workspace", dropZone.workspaceData.id.toString())
                    if (dropZone.overviewRef) {
                        dropZone.overviewRef.close()
                    }
                }
            }
            
            Column {
                anchors.fill: parent
                anchors.margins: 2
                spacing: 2
                
                // Header
                Row {
                    width: parent.width
                    height: 16
                    
                    Text {
                        text: dropZone.workspaceData.name || dropZone.workspaceData.id.toString()
                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Item { 
                        width: parent.width - parent.children[0].width - parent.children[2].width 
                    }
                    
                    Text {
                        text: "(" + dropZone.clients.length + ")"
                        color: "#ffffffb3" // rgba(255, 255, 255, 0.7)
                        font.pixelSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                // Content area
                Item {
                    width: parent.width
                    height: parent.height - 18
                    
                    Repeater {
                        model: dropZone.clients
                        
                        DraggableWindow {
                            id: draggableWindow
                            
                            property var client: modelData
                            property var scaledPos: calculateScaledPosition(client)
                            property var scaledSize: calculateScaledSize(client)
                            
                            x: scaledPos.x
                            y: scaledPos.y
                            width: scaledSize.width
                            height: scaledSize.height
                            
                            clientData: client
                            overviewRef: dropZone.overviewRef
                            monitor: dropZone.monitor
                            containerSize: Qt.size(parent.width, parent.height)
                        }
                    }
                    
                    // Empty workspace indicator
                    Text {
                        visible: dropZone.clients.length === 0
                        text: "Empty"
                        color: "#ffffff80" // rgba(255, 255, 255, 0.5)
                        font.pixelSize: 10
                        font.italic: true
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }

    // Draggable window component
    component DraggableWindow: Rectangle {
        id: windowRect
        
        property var clientData
        property var overviewRef
        property var monitor
        property var containerSize
        property bool isFloating: clientData.floating || false
        property bool isDragging: false
        property bool isHovered: false
        
        color: {
            if (isHovered) {
                return isFloating ? "#4a5568cc" : "#7c7c7ccc"
            }
            return isFloating ? "#4a556866" : "#7c7c7c66"
        }
        
        border.width: isHovered ? 3 : 2
        border.color: {
            if (isHovered) {
                return isFloating ? "#4a5568" : "#7c7c7c"
            }
            return isFloating ? "#4a5568cc" : "#7c7c7ccc"
        }
        
        radius: 12
        
        // Drag functionality
        Drag.active: mouseArea.pressed
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2
        Drag.mimeData: {"window-address": clientData.address}
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            drag.target: parent
            
            property point clickPos
            property bool wasDragged: false
            
            onEntered: windowRect.isHovered = true
            onExited: windowRect.isHovered = false
            
            onPressed: function(mouse) {
                clickPos = Qt.point(mouse.x, mouse.y)
                wasDragged = false
                windowRect.isDragging = true
            }
            
            onPositionChanged: function(mouse) {
                if (pressed) {
                    let dragDistance = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                    if (Math.abs(dragDistance.x) > 5 || Math.abs(dragDistance.y) > 5) {
                        wasDragged = true
                    }
                }
            }
            
            onReleased: function(mouse) {
                windowRect.isDragging = false
                
                if (!wasDragged) {
                    // Single click - focus window and switch workspace
                    if (mouse.button === Qt.LeftButton) {
                        Hyprland.dispatch("workspace", windowRect.clientData.workspace.id.toString())
                        Hyprland.dispatch("focuswindow", "address:" + windowRect.clientData.address)
                        if (windowRect.overviewRef) {
                            windowRect.overviewRef.close()
                        }
                    }
                }
            }
            
            // Right click - switch to workspace
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    Hyprland.dispatch("workspace", windowRect.clientData.workspace.id.toString())
                    if (windowRect.overviewRef) {
                        windowRect.overviewRef.close()
                    }
                }
            }
        }
        
        // Helper functions for scaling
        function calculateScaledPosition(client) {
            if (!client.at || !monitor || !containerSize) return {x: 0, y: 0}
            
            let monitorAspect = monitor.width / monitor.height
            let contentAspect = containerSize.width / containerSize.height
            
            let scale, offsetX, offsetY, scaledWidth, scaledHeight
            
            if (monitorAspect > contentAspect) {
                scale = containerSize.width / monitor.width
                scaledWidth = containerSize.width
                scaledHeight = monitor.height * scale
                offsetX = 0
                offsetY = (containerSize.height - scaledHeight) / 2
            } else {
                scale = containerSize.height / monitor.height
                scaledWidth = monitor.width * scale
                scaledHeight = containerSize.height
                offsetX = (containerSize.width - scaledWidth) / 2
                offsetY = 0
            }
            
            let relativeX = client.at[0] - monitor.x
            let relativeY = client.at[1] - monitor.y
            let scaledX = Math.max(offsetX, 
                Math.min(relativeX * scale + offsetX, 
                        offsetX + scaledWidth - Math.max(12, client.size[0] * scale)))
            let scaledY = Math.max(offsetY,
                Math.min(relativeY * scale + offsetY,
                        offsetY + scaledHeight - Math.max(8, client.size[1] * scale)))
            
            return {x: scaledX, y: scaledY}
        }
        
        function calculateScaledSize(client) {
            if (!client.size || !monitor || !containerSize) return {width: 12, height: 8}
            
            let monitorAspect = monitor.width / monitor.height
            let contentAspect = containerSize.width / containerSize.height
            
            let scale = monitorAspect > contentAspect ? 
                       containerSize.width / monitor.width : 
                       containerSize.height / monitor.height
            
            return {
                width: Math.max(12, client.size[0] * scale),
                height: Math.max(8, client.size[1] * scale)
            }
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: 2
            spacing: 1
            
            // Window title
            Text {
                visible: parent.height > 25
                text: {
                    let maxChars = Math.max(5, parent.width / 8)
                    let title = windowRect.clientData.title || windowRect.clientData.class || "Unknown"
                    return title.length > maxChars ? title.substring(0, maxChars) + "..." : title
                }
                color: "white"
                font.pixelSize: 12
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                elide: Text.ElideRight
            }
            
            // Window class
            Text {
                visible: parent.height > 45
                text: {
                    let maxChars = Math.max(5, parent.width / 8)
                    let className = windowRect.clientData.class || "Unknown"
                    return className.length > maxChars ? className.substring(0, maxChars) : className
                }
                color: "#63b3ed" // color14 equivalent
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                elide: Text.ElideRight
            }
            
            // Icon placeholder (would need proper icon loading implementation)
            Rectangle {
                visible: parent.height > 30
                width: Math.min(parent.width, parent.height) / 3
                height: width
                color: "transparent"
                border.width: 1
                border.color: "#ffffff40"
                radius: 4
                anchors.horizontalCenter: parent.horizontalCenter
                
                Text {
                    anchors.centerIn: parent
                    text: "📱" // Placeholder icon
                    font.pixelSize: parent.width * 0.6
                }
            }
        }
    }

    // Overview Window Component
    component OverviewWindow: LazyLoader {
        id: overviewLoader
        
        property var screen
        property bool active: false
        
        // Load when needed
        loading: active
        
        // Global keybinding to toggle overview
        Shortcut {
            sequence: "Super+Tab"
            onActivated: {
                overviewLoader.active = !overviewLoader.active
            }
        }
        
        LazyLoader {
            active: overviewLoader.active
            
            PanelWindow {
                id: overview
                
                property int cols: 5
                property int rows: 2
                property real percent: 0.78
                property var substituteClassNames: ({"vscode": "codium"})
                property var desktopDirs: ["/usr/share/applications", 
                                          Quickshell.env("HOME") + "/.local/share/applications"]
                
                // Screen dimensions
                property real screenWidth: overviewLoader.screen.width
                property real screenHeight: overviewLoader.screen.height
                property real overviewWidth: screenWidth * percent
                property real overviewHeight: screenHeight * percent
                
                // Workspace dimensions
                property real workspaceWidth: (overviewWidth - 50 - (cols - 1) * 8) / cols
                property real workspaceHeight: (overviewHeight - 50 - (rows - 1) * 8) / rows
                
                // Monitor info
                property var monitorInfo: {
                    return {
                        width: overviewLoader.screen.width,
                        height: overviewLoader.screen.height,
                        x: overviewLoader.screen.x,
                        y: overviewLoader.screen.y
                    }
                }
                
                // Layer shell properties
                screen: overviewLoader.screen
                layer: LayerShell.Overlay
                exclusionMode: LayerShell.ExclusionMode.Ignore
                
                // Window properties
                width: overviewWidth
                height: overviewHeight
                visible: overviewLoader.active
                
                // Center the window
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                
                // Close on Escape key
                Keys.onEscapePressed: {
                    overviewLoader.active = false
                }
                
                // Background
                Rectangle {
                    id: mainContainer
                    anchors.fill: parent
                    color: "transparent"
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 15
                        color: "#0f0f15b3" // rgba(15, 15, 21, 0.7)
                        radius: 14
                        border.width: 2
                        border.color: "#7c7c7c" // color7 equivalent
                        
                        GridLayout {
                            id: workspaceGrid
                            anchors.fill: parent
                            anchors.margins: 10
                            columns: overview.cols
                            rows: overview.rows
                            columnSpacing: 8
                            rowSpacing: 8
                            
                            Repeater {
                                model: overview.cols * overview.rows
                                
                                WorkspaceDropZone {
                                    id: workspaceZone
                                    
                                    property int workspaceId: index + 1
                                    property var workspace: overview.getWorkspaceById(workspaceId)
                                    property var workspaceClients: overview.getClientsForWorkspace(workspaceId)
                                    property bool isActive: Hyprland.activeWorkspace ? 
                                                           Hyprland.activeWorkspace.id === workspaceId : false
                                    
                                    Layout.preferredWidth: overview.workspaceWidth
                                    Layout.preferredHeight: overview.workspaceHeight
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    
                                    workspaceData: workspace
                                    clients: workspaceClients
                                    active: isActive
                                    monitor: overview.monitorInfo
                                    overviewRef: overview
                                }
                            }
                        }
                    }
                }
                
                // Helper functions
                function getWorkspaceById(id) {
                    if (!Hyprland.workspaces) return {id: id, name: id.toString(), windows: 0}
                    
                    for (let i = 0; i < Hyprland.workspaces.length; i++) {
                        if (Hyprland.workspaces[i].id === id) {
                            return Hyprland.workspaces[i]
                        }
                    }
                    return {id: id, name: id.toString(), windows: 0}
                }
                
                function getClientsForWorkspace(workspaceId) {
                    if (!Hyprland.clients) return []
                    
                    let clients = []
                    for (let i = 0; i < Hyprland.clients.length; i++) {
                        let client = Hyprland.clients[i]
                        if (client.workspace && client.workspace.id === workspaceId) {
                            clients.push(client)
                        }
                    }
                    return clients
                }
                
                function close() {
                    overviewLoader.active = false
                }
            }
        }
    }
    
    Variants {
        model: Quickshell.screens
        
        OverviewWindow {
            screen: modelData
        }
    }
}
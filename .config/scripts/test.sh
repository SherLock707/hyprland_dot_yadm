#!/bin/bash

# QuickShell Hyprland Overview Setup Script

# Create directory structure
mkdir -p ~/.config/quickshell/hyprland-overview
mkdir -p ~/.config/quickshell/hyprland-overview/components

# Create main shell file
cat > ~/.config/quickshell/hyprland-overview/shell.qml << 'EOF'
import QtQuick
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    id: root
    
    HyprlandOverview {
        id: overview
    }
    
    // Singleton for global access
    Singleton {
        id: globals
        property alias overview: overview
    }
}
EOF

# Create HyprlandOverview component
cat > ~/.config/quickshell/hyprland-overview/HyprlandOverview.qml << 'EOF'
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Item {
    id: overview
    
    property int cols: 5
    property int rows: 2
    property real percent: 0.78
    property bool visible: false
    
    // Hyprland connection
    property var hyprland: HyprlandIpc {}
    
    // Data properties
    property var workspaces: []
    property var clients: []
    property var activeWorkspace: null
    property var monitors: []
    
    function refreshData() {
        try {
            let workspacesResult = hyprland.requestSocket("j/workspaces")
            let clientsResult = hyprland.requestSocket("j/clients") 
            let activeResult = hyprland.requestSocket("j/activeworkspace")
            let monitorsResult = hyprland.requestSocket("j/monitors")
            
            workspaces = JSON.parse(workspacesResult)
            clients = JSON.parse(clientsResult)
            activeWorkspace = JSON.parse(activeResult)
            monitors = JSON.parse(monitorsResult)
            
            console.log("Data refreshed - Workspaces:", workspaces.length, "Clients:", clients.length)
        } catch (e) {
            console.error("Failed to refresh Hyprland data:", e)
        }
    }
    
    function show() {
        refreshData()
        visible = true
        overlayWindow.visible = true
    }
    
    function hide() {
        visible = false
        overlayWindow.visible = false
    }
    
    function toggle() {
        if (visible) {
            hide()
        } else {
            show()
        }
    }
    
    // Main overlay window
    WlrLayershell {
        id: overlayWindow
        visible: overview.visible
        layer: WlrLayer.Overlay
        keyboardFocus: WlrKeyboardFocus.OnDemand
        anchor: WlrAnchors.Left | WlrAnchors.Right | WlrAnchors.Top | WlrAnchors.Bottom
        
        width: Screen.width * overview.percent
        height: Screen.height * overview.percent
        
        color: "transparent"
        
        Rectangle {
            id: background
            anchors.fill: parent
            color: "#1e1e2e"
            opacity: 0.95
            radius: 12
            border.color: "#313244"
            border.width: 2
        }
        
        WorkspaceGrid {
            id: workspaceGrid
            anchors.centerIn: parent
            width: parent.width - 50
            height: parent.height - 50
            
            cols: overview.cols
            rows: overview.rows
            
            workspaces: overview.workspaces
            clients: overview.clients
            activeWorkspace: overview.activeWorkspace
            monitors: overview.monitors
            hyprland: overview.hyprland
            
            onCloseRequested: overview.hide()
        }
        
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                overview.hide()
                event.accepted = true
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: overview.hide()
            z: -1
        }
    }
    
    Component.onCompleted: {
        console.log("HyprlandOverview initialized")
    }
}
EOF

# Create WorkspaceGrid component
cat > ~/.config/quickshell/hyprland-overview/WorkspaceGrid.qml << 'EOF'
import QtQuick
import QtQuick.Layouts

GridLayout {
    id: workspaceGrid
    
    property int cols: 5
    property int rows: 2
    property var workspaces: []
    property var clients: []
    property var activeWorkspace: null
    property var monitors: []
    property var hyprland: null
    
    signal closeRequested()
    
    columns: cols
    rowSpacing: 8
    columnSpacing: 8
    
    Repeater {
        model: cols * rows
        
        WorkspaceDropZone {
            id: workspaceItem
            
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 200
            Layout.minimumHeight: 120
            
            property int workspaceId: index + 1
            property var workspace: getWorkspaceById(workspaceId)
            
            clients: workspaceGrid.clients
            isActive: workspaceGrid.activeWorkspace ? workspaceGrid.activeWorkspace.id === workspaceId : false
            monitors: workspaceGrid.monitors
            hyprland: workspaceGrid.hyprland
            
            onCloseRequested: workspaceGrid.closeRequested()
            
            function getWorkspaceById(id) {
                for (let ws of workspaces) {
                    if (ws.id === id) {
                        return ws
                    }
                }
                return {
                    id: id,
                    name: id.toString(),
                    windows: 0,
                    monitor: monitors.length > 0 ? monitors[0].name : "Unknown"
                }
            }
        }
    }
}
EOF

# Create WorkspaceDropZone component
cat > ~/.config/quickshell/hyprland-overview/WorkspaceDropZone.qml << 'EOF'
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: workspaceZone
    
    property var workspace: ({})
    property var clients: []
    property bool isActive: false
    property var monitors: []
    property var hyprland: null
    
    signal closeRequested()
    
    color: isActive ? "#313244" : "#181825"
    border.color: isActive ? "#89b4fa" : "#45475a"
    border.width: 2
    radius: 8
    
    // Drag and drop support
    DropArea {
        id: dropArea
        anchors.fill: parent
        
        property bool dragHovered: false
        
        onEntered: function(drag) {
            dragHovered = true
            workspaceZone.border.color = "#f9e2af"
            workspaceZone.border.width = 3
        }
        
        onExited: {
            dragHovered = false
            workspaceZone.border.color = isActive ? "#89b4fa" : "#45475a"
            workspaceZone.border.width = 2
        }
        
        onDropped: function(drop) {
            if (drop.hasText) {
                let windowAddress = drop.text
                console.log("Moving window", windowAddress, "to workspace", workspace.id)
                
                if (hyprland) {
                    hyprland.dispatch("movetoworkspacesilent " + workspace.id + ",address:" + windowAddress)
                }
            }
            dragHovered = false
            workspaceZone.border.color = isActive ? "#89b4fa" : "#45475a"
            workspaceZone.border.width = 2
        }
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4
        
        // Header
        Row {
            width: parent.width
            spacing: 8
            
            Text {
                text: workspace.name || workspace.id
                color: "#cdd6f4"
                font.bold: isActive
                font.pixelSize: 14
            }
            
            Item { width: parent.width - 60 }
            
            Text {
                text: "(" + getWorkspaceClientCount() + ")"
                color: "#6c7086"
                font.pixelSize: 12
            }
        }
        
        // Window layout area
        Rectangle {
            width: parent.width
            height: parent.height - 30
            color: "transparent"
            
            Repeater {
                model: getWorkspaceClients()
                
                DraggableWindow {
                    id: windowItem
                    client: modelData
                    workspaceZone: workspaceZone
                    monitors: workspaceZone.monitors
                    hyprland: workspaceZone.hyprland
                    
                    onCloseRequested: workspaceZone.closeRequested()
                }
            }
        }
    }
    
    // Click to switch workspace
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (hyprland) {
                hyprland.dispatch("workspace " + workspace.id)
                closeRequested()
            }
        }
        z: -1
    }
    
    function getWorkspaceClients() {
        let result = []
        for (let client of clients) {
            if (client.workspace && client.workspace.id === workspace.id) {
                result.push(client)
            }
        }
        return result
    }
    
    function getWorkspaceClientCount() {
        return getWorkspaceClients().length
    }
}
EOF

# Create DraggableWindow component
cat > ~/.config/quickshell/hyprland-overview/DraggableWindow.qml << 'EOF'
import QtQuick

Rectangle {
    id: windowRect
    
    property var client: ({})
    property var workspaceZone: null
    property var monitors: []
    property var hyprland: null
    
    signal closeRequested()
    
    // Calculate position and size based on actual window geometry
    Component.onCompleted: calculateGeometry()
    
    function calculateGeometry() {
        if (!client.at || !client.size || monitors.length === 0) {
            // Default positioning
            x = Math.random() * Math.max(1, parent.width - 80)
            y = Math.random() * Math.max(1, parent.height - 40)
            width = 80
            height = 40
            return
        }
        
        let monitor = monitors[0] // Assuming primary monitor for now
        let monitorWidth = monitor.width || 1920
        let monitorHeight = monitor.height || 1080
        
        // Scale factor to fit workspace
        let scaleX = parent.width / monitorWidth
        let scaleY = parent.height / monitorHeight
        let scale = Math.min(scaleX, scaleY) * 0.8 // Leave some margin
        
        // Calculate scaled position and size
        x = client.at[0] * scale
        y = client.at[1] * scale
        width = Math.max(20, client.size[0] * scale)
        height = Math.max(15, client.size[1] * scale)
        
        // Ensure window stays within bounds
        x = Math.max(0, Math.min(x, parent.width - width))
        y = Math.max(0, Math.min(y, parent.height - height))
    }
    
    color: client.floating ? "#f38ba8" : "#94e2d5"
    opacity: dragArea.drag.active ? 0.7 : 1.0
    border.color: "#45475a"
    border.width: 1
    radius: 4
    
    // Window content
    Column {
        anchors.centerIn: parent
        anchors.margins: 2
        spacing: 1
        
        Text {
            text: (client.title || client.class || "Unknown").substring(0, 10)
            color: "#1e1e2e"
            font.pixelSize: Math.max(8, Math.min(12, windowRect.width / 8))
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            width: windowRect.width - 4
            elide: Text.ElideRight
        }
        
        Text {
            text: (client.class || "").substring(0, 8)
            color: "#1e1e2e"
            font.pixelSize: Math.max(6, Math.min(10, windowRect.width / 10))
            horizontalAlignment: Text.AlignHCenter
            width: windowRect.width - 4
            elide: Text.ElideRight
            visible: windowRect.height > 25
        }
    }
    
    // Drag functionality
    Drag.active: dragArea.drag.active
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2
    Drag.mimeData: { "text/plain": client.address || "" }
    
    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag.target: parent
        
        property bool dragActive: false
        
        onPressed: {
            dragActive = true
            parent.z = 100 // Bring to front
        }
        
        onReleased: {
            dragActive = false
            parent.z = 1
        }
        
        onClicked: {
            if (!dragActive) {
                // Focus window and switch workspace
                if (client.address && hyprland) {
                    hyprland.dispatch("workspace " + client.workspace.id)
                    hyprland.dispatch("focuswindow address:" + client.address)
                    closeRequested()
                }
            }
        }
    }
    
    // Hover effects
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        
        onEntered: {
            windowRect.scale = 1.1
            windowRect.z = 50
        }
        
        onExited: {
            windowRect.scale = 1.0
            windowRect.z = 1
        }
        
        onPressed: function(mouse) { mouse.accepted = false }
        onReleased: function(mouse) { mouse.accepted = false }
        onClicked: function(mouse) { mouse.accepted = false }
    }
    
    Behavior on scale {
        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
    }
    
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }
}
EOF

# Create manifest file
cat > ~/.config/quickshell/hyprland-overview/quickshell.qml << 'EOF'
import Quickshell

ShellRoot {
    Variants {
        variants: ["hyprland-overview"]
        
        HyprlandOverview {
            id: overview
        }
    }
}
EOF

echo "QuickShell Hyprland Overview configuration created!"
echo "Files created in ~/.config/quickshell/hyprland-overview/"
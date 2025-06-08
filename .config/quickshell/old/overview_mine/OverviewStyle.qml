// style.qml
pragma Singleton
import QtQuick 2.0
QtObject {
    // Overall overview panel background
    property color backgroundColor: "#222222"
    // Workspace tile colors
    property color workspaceBg: "#333333"
    property color workspaceActiveBg: "#444444"
    property color borderColor: "#555555"
    property color textColor: "#ffffff"
    // Sizing parameters (tunable as needed)
    property real overviewWidth: 0.8       // 80% of screen width
    property real overviewHeight: 0.8      // 80% of screen height
    property int columns: 4               // Number of workspace columns in grid
    property int spacing: 8               // Spacing between grid items
    property real windowPreviewScale: 0.3 // Scale of window thumbnails within workspace tile
    property int borderRadius: 4          // Corner radius for panels
}

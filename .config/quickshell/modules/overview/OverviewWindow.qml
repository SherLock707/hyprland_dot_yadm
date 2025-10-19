import "root:/"
import "root:/services/"
import "root:/modules/common"
import "root:/modules/common/widgets"
import "root:/modules/common/functions/color_utils.js" as ColorUtils
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

Item { // Window
    id: root
    property var toplevel
    property var windowData
    property var monitorData
    property var scale
    property var availableWorkspaceWidth
    property var availableWorkspaceHeight
    property bool restrictToWorkspace: true``
    property real initX: Math.max((windowData?.at[0] - (monitorData?.x ?? 0) - monitorData?.reserved[0]) * root.scale, 0) + xOffset
    property real initY: Math.max((windowData?.at[1] - (monitorData?.y ?? 0) - monitorData?.reserved[1]) * root.scale, 0) + yOffset
    property real xOffset: 0
    property real yOffset: 0
    
    property var targetWindowWidth: windowData?.size[0] * scale
    property var targetWindowHeight: windowData?.size[1] * scale
    property bool hovered: false
    property bool pressed: false

    property var iconToWindowRatio: 0.35
    property var xwaylandIndicatorToIconRatio: 0.35
    property var iconToWindowRatioCompact: 0.6
    property var iconPath: Quickshell.iconPath(AppSearch.guessIcon(windowData?.class), "image-missing")
    property bool compactMode: Appearance.font.pixelSize.textSmall * 4 > targetWindowHeight || Appearance.font.pixelSize.textSmall * 4 > targetWindowWidth

    property bool indicateXWayland: windowData?.xwayland ?? false

    property url backgroundImage: ""  // Path to the image file (can be empty)
    property int draggingFromWorkspace: -1
    property int draggingTargetWorkspace: -1
    
    x: initX
    y: initY
    width: Math.min(windowData?.size[0] * root.scale, (restrictToWorkspace ? windowData?.size[0] : availableWorkspaceWidth - x + xOffset))
    height: Math.min(windowData?.size[1] * root.scale, (restrictToWorkspace ? windowData?.size[1] : availableWorkspaceHeight - y + yOffset))

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: Appearance.rounding.windowRounding * root.scale
        }
    }

    // Window border
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: Appearance.rounding.windowRounding * root.scale
        border.color: ColorUtils.transparentize(Appearance.m3colors.m3borderPrimary, 0.4)
        border.pixelAligned: false
        border.width: 2
    }

    Behavior on x {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    Behavior on y {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    Behavior on width {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    Behavior on height {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }

    // --- Background Layer ---
    ScreencopyView {
        id: windowPreview
        anchors.fill: parent
        captureSource: GlobalStates.overviewOpen ? root.toplevel : null
        live: ConfigOptions.overview.liveCapture
        visible: GlobalStates.overviewOpen && root.toplevel
        z: -1
        // Let it capture at natural resolution with best scaling
        smooth: true
        antialiasing: true
        // Remove sourceSize to let it capture at natural resolution
    }

    Image {
        id: bg
        anchors.fill: parent
        source: root.backgroundImage
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        visible: source !== "" && !windowPreview.visible
        smooth: true
        opacity: 0.9
        z: -1
    }

        Image {
            id: windowIcon
            anchors.centerIn: parent
            property var iconSize: Math.min(targetWindowWidth, targetWindowHeight) * (root.compactMode ? root.iconToWindowRatioCompact : root.iconToWindowRatio)
            source: root.iconPath
            width: iconSize
            height: iconSize
            sourceSize: Qt.size(iconSize, iconSize)

            Behavior on width {
                animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
            }
            Behavior on height {
                animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
            }
        }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: hovered = true
        onExited: hovered = false
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        drag.target: parent
        onPressed: {
            root.draggingFromWorkspace = windowData?.workspace.id
            root.pressed = true
            root.Drag.active = true
            root.Drag.source = root
        }
        onReleased: {
            const targetWorkspace = root.draggingTargetWorkspace
            root.pressed = false
            root.Drag.active = false
            root.draggingFromWorkspace = -1
            if (targetWorkspace !== -1 && targetWorkspace !== windowData?.workspace.id) {
                Hyprland.dispatch(`movetoworkspacesilent ${targetWorkspace}, address:${root.windowData?.address}`)
                updateWindowPosition.restart()
            }
            else {
                root.x = root.initX
                root.y = root.initY
            }
        }
        onClicked: (event) => {
            if (!windowData) return;

            if (event.button === Qt.LeftButton) {
                GlobalStates.overviewOpen = false
                Hyprland.dispatch(`focuswindow address:${windowData.address}`)
                event.accepted = true
            } else if (event.button === Qt.MiddleButton) {
                Hyprland.dispatch(`closewindow address:${windowData.address}`)
                event.accepted = true
            }
        }

        StyledToolTip {
            extraVisibleCondition: false
            alternativeVisibleCondition: dragArea.containsMouse && !root.Drag.active
            content: `${windowData.title}\n[${windowData.class}] ${windowData.xwayland ? "[XWayland] " : ""}\n`
        }
    }

    Timer {
        id: updateWindowPosition
        interval: ConfigOptions.hacks.arbitraryRaceConditionDelay
        repeat: false
        running: false
        onTriggered: {
            root.x = Math.max((windowData?.at[0] - monitorData?.reserved[0] - monitorData?.x) * root.scale, 0) + xOffset
            root.y = Math.max((windowData?.at[1] - monitorData?.reserved[1] - monitorData?.y) * root.scale, 0) + yOffset
        }
    }
}
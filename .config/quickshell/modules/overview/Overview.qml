import "root:/"
import "root:/services"
import "root:/modules/common"
import "root:/modules/common/widgets"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: overviewScope
    property bool dontAutoCancelSearch: false
    property bool searchEnabled: ConfigOptions.search.searchEnabled
    
    Variants {
        id: overviewVariants
        model: Quickshell.screens.filter(s => Hyprland.monitorFor(s).id === Hyprland.focusedMonitor?.id)
        PanelWindow {
            id: root
            required property var modelData
            property string searchingText: ""
            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor.id)
            screen: modelData
            visible: GlobalStates.overviewOpen

            WlrLayershell.namespace: "quickshell:overview"
            WlrLayershell.layer: WlrLayer.Overlay
            color: "transparent"

            mask: Region {
                item: GlobalStates.overviewOpen ? columnLayout : null
            }
            HyprlandWindow.visibleMask: Region {
                item: GlobalStates.overviewOpen ? columnLayout : null
            }

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            HyprlandFocusGrab {
                id: grab
                windows: [ root ]
                property bool canBeActive: root.monitorIsFocused
                active: GlobalStates.overviewOpen
            }

            Connections {
                target: GlobalStates
                function onOverviewOpenChanged() {
                    if (!GlobalStates.overviewOpen) {
                        if (overviewScope.searchEnabled && searchWidgetLoader.item) {
                            searchWidgetLoader.item.disableExpandAnimation()
                        }
                        overviewScope.dontAutoCancelSearch = false;
                    } else {
                        if (!overviewScope.dontAutoCancelSearch && overviewScope.searchEnabled && searchWidgetLoader.item) {
                            searchWidgetLoader.item.cancelSearch()
                        }
                        delayedGrabTimer.start()
                    }
                }
            }

            Timer {
                id: delayedGrabTimer
                interval: ConfigOptions.hacks.arbitraryRaceConditionDelay
                repeat: false
                onTriggered: {
                    if (!grab.canBeActive) return
                    grab.active = GlobalStates.overviewOpen
                }
            }

            implicitWidth: columnLayout.implicitWidth
            implicitHeight: columnLayout.implicitHeight

            function setSearchingText(text) {
                if (overviewScope.searchEnabled && searchWidgetLoader.item) {
                    searchWidgetLoader.item.setSearchingText(text);
                }
            }

            ColumnLayout {
                id: columnLayout
                visible: GlobalStates.overviewOpen
                focus: true
                activeFocusOnTab: true
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: ConfigOptions.overview.position === 0 ? parent.top : undefined
                    verticalCenter: ConfigOptions.overview.position === 1 ? parent.verticalCenter : undefined
                    bottom: ConfigOptions.overview.position === 2 ? parent.bottom : undefined
                }

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        GlobalStates.overviewOpen = false;
                        event.accepted = true
                    }
                }

                Item {
                    height: 1
                    width: 1
                }

                // FIX: Use Loader to conditionally load SearchWidget ONLY when searchEnabled is true
                Loader {
                    id: searchWidgetLoader
                    Layout.alignment: Qt.AlignHCenter
                    active: overviewScope.searchEnabled
                    visible: overviewScope.searchEnabled
                    Layout.preferredHeight: (overviewScope.searchEnabled && item) ? item.implicitHeight : 0
                    
                    sourceComponent: overviewScope.searchEnabled ? searchWidgetComponent : null
                    
                    onLoaded: {
                        if (item) {
                            item.searchingTextChanged.connect(function(text) {
                                root.searchingText = item.searchingText
                            })
                        }
                    }
                }
                
                Component {
                    id: searchWidgetComponent
                    SearchWidget {}
                }

                Item {
                    Layout.preferredHeight: overviewScope.searchEnabled ? 0 : 20
                    Layout.fillWidth: true
                    visible: !overviewScope.searchEnabled
                }

                // FIX: Use Loader to load OverviewWidget from file
                Loader {
                    id: overviewWidgetLoader
                    active: GlobalStates.overviewOpen
                    Layout.alignment: Qt.AlignHCenter
                    
                    sourceComponent: overviewWidgetComponent
                }
                
                Component {
                    id: overviewWidgetComponent
                    OverviewWidget {
                        panelWindow: root
                        // Show OverviewWidget when search is disabled OR when search text is empty
                        visible: !overviewScope.searchEnabled || (root.searchingText == "")
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "overview"

        function toggle() {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen
        }
        function close() {
            GlobalStates.overviewOpen = false
        }
        function open() {
            GlobalStates.overviewOpen = true
        }
        function toggleReleaseInterrupt() {
            GlobalStates.superReleaseMightTrigger = false
        }
        function toggleSearch() {
            overviewScope.searchEnabled = !overviewScope.searchEnabled
        }
        function enableSearch() {
            overviewScope.searchEnabled = true
        }
        function disableSearch() {
            overviewScope.searchEnabled = false
        }
    }

    GlobalShortcut {
        name: "overviewToggle"
        description: qsTr("Toggles overview on press")

        onPressed: {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen   
        }
    }
    
    GlobalShortcut {
        name: "overviewClose"
        description: qsTr("Closes overview")

        onPressed: {
            GlobalStates.overviewOpen = false
        }
    }
    
    GlobalShortcut {
        name: "overviewToggleRelease"
        description: qsTr("Toggles overview on release")

        onPressed: {
            GlobalStates.superReleaseMightTrigger = true
        }

        onReleased: {
            if (!GlobalStates.superReleaseMightTrigger) {
                GlobalStates.superReleaseMightTrigger = true
                return
            }
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen   
        }
    }
    
    GlobalShortcut {
        name: "overviewToggleReleaseInterrupt"
        description: qsTr("Interrupts possibility of overview being toggled on release. ") +
            qsTr("This is necessary because GlobalShortcut.onReleased in quickshell triggers whether or not you press something else while holding the key. ") +
            qsTr("To make sure this works consistently, use binditn = MODKEYS, catchall in an automatically triggered submap that includes everything.")

        onPressed: {
            GlobalStates.superReleaseMightTrigger = false
        }
    }
    
    GlobalShortcut {
        name: "overviewClipboardToggle"
        description: qsTr("Toggle clipboard query on overview widget")

        onPressed: {
            if (!overviewScope.searchEnabled) return;
            
            if (GlobalStates.overviewOpen && overviewScope.dontAutoCancelSearch) {
                GlobalStates.overviewOpen = false;
                return;
            }
            for (let i = 0; i < overviewVariants.instances.length; i++) {
                let panelWindow = overviewVariants.instances[i];
                if (panelWindow.modelData.name == Hyprland.focusedMonitor.name) {
                    overviewScope.dontAutoCancelSearch = true;
                    panelWindow.setSearchingText(
                        ConfigOptions.search.prefix.clipboard
                    );
                    GlobalStates.overviewOpen = true;
                    return
                }
            }
        }
    }

    GlobalShortcut {
        name: "overviewEmojiToggle"
        description: qsTr("Toggle emoji query on overview widget")

        onPressed: {
            if (!overviewScope.searchEnabled) return;
            
            if (GlobalStates.overviewOpen && overviewScope.dontAutoCancelSearch) {
                GlobalStates.overviewOpen = false;
                return;
            }
            for (let i = 0; i < overviewVariants.instances.length; i++) {
                let panelWindow = overviewVariants.instances[i];
                if (panelWindow.modelData.name == Hyprland.focusedMonitor.name) {
                    overviewScope.dontAutoCancelSearch = true;
                    panelWindow.setSearchingText(
                        ConfigOptions.search.prefix.emojis
                    );
                    GlobalStates.overviewOpen = true;
                    return
                }
            }
        }
    }

    GlobalShortcut {
        name: "overviewToggleSearch"
        description: qsTr("Toggle search functionality in overview")

        onPressed: {
            overviewScope.searchEnabled = !overviewScope.searchEnabled
        }
    }
}
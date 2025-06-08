pragma Singleton
pragma ComponentBehavior: Bound

import "root:/modules/common/functions/file_utils.js" as FileUtils
import Qt.labs.platform
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    // XDG Dirs, with "file://"
    readonly property string config: StandardPaths.standardLocations(StandardPaths.ConfigLocation)[0]
    readonly property string state: StandardPaths.standardLocations(StandardPaths.StateLocation)[0]
    readonly property string cache: StandardPaths.standardLocations(StandardPaths.CacheLocation)[0]
    
    // Other dirs used by the shell, without "file://"
    property string favicons: FileUtils.trimFileProtocol(`${Directories.cache}/media/favicons`)
    property string shellConfig: FileUtils.trimFileProtocol(`${Directories.config}/quickshell`)
    property string shellConfigName: "config.json"
    property string shellConfigPath: `${Directories.shellConfig}/${Directories.shellConfigName}`
    // property string notificationsPath: FileUtils.trimFileProtocol(`${Directories.cache}/notifications/notifications.json`)
    property string generatedMaterialThemePath: FileUtils.trimFileProtocol(`${Directories.config}/quickshell/colors.json`)
    // Cleanup on init
    // Component.onCompleted: {
    //     Hyprland.dispatch(`exec mkdir -p '${favicons}'`)
    //     Hyprland.dispatch(`exec rm -rf '${coverArt}'; mkdir -p '${coverArt}'`)
    //     Hyprland.dispatch(`exec rm -rf '${booruPreviews}'; mkdir -p '${booruPreviews}'`)
    //     Hyprland.dispatch(`exec mkdir -p '${booruDownloads}' && mkdir -p '${booruDownloadsNsfw}'`)
    //     Hyprland.dispatch(`exec rm -rf '${latexOutput}'; mkdir -p '${latexOutput}'`)
    //     Hyprland.dispatch(`exec rm -rf '${cliphistDecode}'; mkdir -p '${cliphistDecode}'`)
    // }
}

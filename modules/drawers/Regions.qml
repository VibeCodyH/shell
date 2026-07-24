pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config

Region {
    id: root

    required property EdgeGeometry geometry
    required property Panels panels
    required property var win

    readonly property real borderThickness: win.contentItem.Config.border.thickness
    readonly property real clampedThickness: win.contentItem.Config.border.clampedThickness

    x: geometry.insetLeft(clampedThickness, true) + win.dragMaskPadding
    y: geometry.insetTop(clampedThickness, true) + win.dragMaskPadding
    width: win.width - geometry.insetLeft(clampedThickness, true) - clampedThickness - win.dragMaskPadding * 2
    height: win.height - geometry.insetTop(clampedThickness, true) - geometry.insetBottom(clampedThickness, true) - win.dragMaskPadding * 2
    intersection: Intersection.Xor

    R {
        panel: root.panels.dashboard
        x: root.geometry.dashboardOnLeft ? 0 : panel.x + root.geometry.insetLeft(root.borderThickness)
        y: root.geometry.dashboardOnLeft ? panel.y + root.geometry.insetTop(root.borderThickness) : 0
        width: root.geometry.dashboardOnLeft ? panel.width * (1 - root.panels.dashboard.offsetScale) + root.geometry.insetLeft(root.borderThickness) : panel.width
        height: root.geometry.dashboardOnLeft ? panel.height : panel.height * (1 - root.panels.dashboard.offsetScale) + root.geometry.insetTop(root.borderThickness)
    }

    R {
        panel: root.panels.launcher
        y: root.win.height - height
        height: panel.height * (1 - root.panels.launcher.offsetScale) + root.geometry.insetBottom(root.borderThickness)
    }

    R {
        id: sessionRegion

        panel: root.panels.sessionWrapper
        x: root.win.width - width
        width: panel.width * (1 - root.panels.session.offsetScale) + root.borderThickness + sidebarRegion.width
    }

    R {
        id: sidebarRegion

        panel: root.panels.sidebar
        x: root.win.width - width
        width: panel.width * (1 - root.panels.sidebar.offsetScale) + root.borderThickness
    }

    R {
        panel: root.panels.osdWrapper
        x: root.win.width - width
        width: panel.width * (1 - root.panels.osd.offsetScale) + root.borderThickness + sessionRegion.width
    }

    R {
        panel: root.panels.notifications
        y: 0
        height: panel.height + root.geometry.insetTop(root.borderThickness)
    }

    R {
        panel: root.panels.utilities
        y: root.win.height - height
        height: panel.height * (1 - root.panels.utilities.offsetScale) + root.geometry.insetBottom(root.borderThickness)
    }

    // Union of where the popout is and where it is headed. Cut from the animated geometry alone,
    // this hole lags the popout as it slides between two bar entries or grows out of the bar, so a
    // cursor moving into the popout it just opened lands outside the mask and is handed to the
    // window underneath — the shell sees a pointer leave and dismisses the popout the cursor was
    // aiming for. Union so the hole only ever leads the animation, never trails it. No offsetScale
    // factor here: ClipWrapper already applies it to the axis that collapses.
    R {
        readonly property real unionX: Math.min(panel.x, panel.settledX)
        readonly property real unionY: Math.min(panel.y, panel.settledY)

        panel: root.panels.popoutsWrapper
        x: unionX + root.geometry.insetLeft(root.borderThickness)
        y: unionY + root.geometry.insetTop(root.borderThickness)
        width: Math.max(panel.x + panel.width, panel.settledX + panel.settledWidth) - unionX
        height: Math.max(panel.y + panel.height, panel.settledY + panel.settledHeight) - unionY
    }

    component R: Region {
        required property Item panel

        x: panel.x + root.geometry.insetLeft(root.borderThickness)
        y: panel.y + root.geometry.insetTop(root.borderThickness)
        width: panel.width
        height: panel.height
        intersection: Intersection.Subtract
    }
}

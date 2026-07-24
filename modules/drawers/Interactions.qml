import QtQuick
import QtQuick.Controls
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.modules.bar as Bar
import qs.modules.bar.popouts as BarPopouts

CustomMouseArea {
    id: root

    required property ShellScreen screen
    required property BarPopouts.Wrapper popouts
    required property ScreenState screenState
    required property Panels panels
    required property Bar.BarWrapper bar
    required property EdgeGeometry geometry
    required property real borderThickness
    required property bool fullscreen

    property point dragStart
    property bool dashboardShortcutActive
    property bool osdShortcutActive
    property bool utilitiesShortcutActive

    function withinPanelHeight(panel: Item, x: real, y: real): bool {
        const panelY = geometry.insetTop(borderThickness) + panel.y;
        return y >= panelY - Config.border.rounding && y <= panelY + panel.height + Config.border.rounding;
    }

    function withinPanelWidth(panel: Item, x: real, y: real): bool {
        const panelX = geometry.insetLeft(borderThickness) + panel.x;
        return x >= panelX - Config.border.rounding && x <= panelX + panel.width + Config.border.rounding;
    }

    function inLeftPanel(panel: Item, x: real, y: real): bool {
        return x < geometry.insetLeft(borderThickness) + panel.x + panel.width && withinPanelHeight(panel, x, y);
    }

    function inRightPanel(panel: Item, x: real, y: real): bool {
        return x > Math.min(width - Config.border.minThickness, geometry.insetLeft(borderThickness) + panel.x) && withinPanelHeight(panel, x, y);
    }

    function inTopPanel(panel: Item, x: real, y: real): bool {
        const panelHeight = panel.height * (1 - (panel.offsetScale ?? 0)); // qmllint disable missing-property
        return y < Math.max(Config.border.minThickness, geometry.insetTop(Config.border.thickness) + panelHeight) && withinPanelWidth(panel, x, y);
    }

    function inBottomPanel(panel: Item, x: real, y: real, isCorner = false): bool {
        const panelHeight = panel.height * (1 - (panel.offsetScale ?? 0)); // qmllint disable missing-property
        return y > height - Math.max(Config.border.minThickness, geometry.insetBottom(Config.border.thickness) + panelHeight) - (isCorner ? Config.border.rounding : 0) && withinPanelWidth(panel, x, y);
    }

    // Keep-open test for the bar popouts. The popout wrapper animates open — its size grows from
    // zero and, on a bottom bar, its y trails that growth — so for the first frames the region is
    // a sliver pinned to the bar. Testing the cursor against that CURRENT rect closes the popout
    // whenever you leave the bar faster than it grows, which is why it only survived a slow move.
    // Test the size it is animating toward instead. Every term here only widens what inLeftPanel
    // already accepted (the x bound stays one-sided), so no bar position loses hover.
    function inPopoutArea(x: real, y: real): bool {
        const panel = panels.popoutsWrapper;
        const w = Math.max(panel.width, popouts.nonAnimWidth);
        const h = Math.max(panel.height, popouts.nonAnimHeight);
        const panelX = geometry.insetLeft(borderThickness) + panel.x;
        const panelY = geometry.insetTop(borderThickness) + panel.y;
        // Grow from the edge the popout is pinned to, not the one it animates away from
        const top = geometry.barOnBottom ? panelY + panel.height - h : panelY;
        return x < panelX + w && y >= top - Config.border.rounding && y <= top + h + Config.border.rounding;
    }

    function inDashboardArea(x: real, y: real): bool {
        if (geometry.dashboardOnLeft) {
            if (geometry.barOnLeft && geometry.barContains(x, y))
                return false;
            const panelWidth = panels.dashboard.width * (1 - panels.dashboard.offsetScale);
            return x < Math.max(Config.border.minThickness, geometry.insetLeft(Config.border.thickness) + panelWidth) && withinPanelHeight(panels.dashboard, x, y);
        }
        if (geometry.barOnTop && geometry.barContains(x, y))
            return false;
        return inTopPanel(panels.dashboard, x, y);
    }

    function onWheel(event: WheelEvent): void {
        if (fullscreen)
            return;
        if (geometry.barContains(event.x, event.y)) {
            bar.handleWheel(geometry.axisPos(event.x, event.y), event.angleDelta);
        }
    }

    anchors.fill: parent
    acceptedButtons: fullscreen ? Qt.NoButton : Qt.AllButtons
    hoverEnabled: true

    onPressed: event => dragStart = Qt.point(event.x, event.y)
    onContainsMouseChanged: {
        if (!containsMouse) {
            // Only hide if not activated by shortcut
            if (!osdShortcutActive) {
                screenState.osd = false;
                root.panels.osd.hovered = false;
            }

            if (!dashboardShortcutActive)
                screenState.dashboard = false;

            if (!utilitiesShortcutActive)
                screenState.utilities = false;

            if (!popouts.currentName.startsWith("traymenu") || ((popouts.current as StackView)?.depth ?? 0) <= 1) {
                popouts.hasCurrent = false;
                bar.closeTray();
            }

            if (Config.bar.showOnHover)
                bar.isHovered = false;

            if (Config.sidebar.showOnHover)
                screenState.sidebar = false;
        }
    }

    onPositionChanged: event => {
        if (popouts.isDetached)
            return;

        const x = event.x;
        const y = event.y;
        const dragX = x - dragStart.x;
        const dragY = y - dragStart.y;

        if (fullscreen) {
            root.panels.osd.hovered = inRightPanel(panels.osdWrapper, x, y);
            return;
        }

        // Show bar in non-exclusive mode on hover
        if (!screenState.bar && Config.bar.showOnHover && geometry.barContains(x, y, true))
            bar.isHovered = true;

        // Show/hide bar on drag
        if (pressed && geometry.barContains(dragStart.x, dragStart.y, true)) {
            const barDrag = geometry.inwardDrag(dragX, dragY);
            if (barDrag > Config.bar.dragThreshold)
                screenState.bar = true;
            else if (barDrag < -Config.bar.dragThreshold)
                screenState.bar = false;
        }

        if (panels.sidebar.offsetScale === 1) {
            // Show osd on hover
            const showOsd = inRightPanel(panels.osdWrapper, x, y);

            // Always update visibility based on hover if not in shortcut mode
            if (!osdShortcutActive) {
                screenState.osd = showOsd;
                root.panels.osd.hovered = showOsd;
            } else if (showOsd) {
                // If hovering over OSD area while in shortcut mode, transition to hover control
                osdShortcutActive = false;
                root.panels.osd.hovered = true;
            }

            const showSidebar = pressed && dragStart.x > Math.min(width - Config.border.minThickness, geometry.insetLeft(borderThickness) + panels.sidebar.x);

            // Show sidebar on hover (top-right corner, bounded by notification panel height)
            if (Config.sidebar.showOnHover) {
                const sidebarTriggerY = Math.max(Config.sidebar.minHoverThreshold, panels.notifications.y + panels.notifications.height + borderThickness);
                const showSidebarHover = x > Math.min(width - Config.border.minThickness, geometry.insetLeft(borderThickness) + panels.sidebar.x) && y <= sidebarTriggerY;
                if (showSidebarHover && !screenState.sidebar)
                    screenState.sidebar = true;
            }

            // Show/hide session on drag
            if (pressed && inRightPanel(panels.sessionWrapper, dragStart.x, dragStart.y) && withinPanelHeight(panels.sessionWrapper, x, y)) {
                if (dragX < -Config.session.dragThreshold)
                    screenState.session = true;
                else if (dragX > Config.session.dragThreshold)
                    screenState.session = false;

                // Show sidebar on drag if in session area and session is nearly fully visible
                if (showSidebar && panels.session.offsetScale <= 0 && dragX < -Config.sidebar.dragThreshold)
                    screenState.sidebar = true;
            } else if (showSidebar && dragX < -Config.sidebar.dragThreshold) {
                // Show sidebar on drag if not in session area
                screenState.sidebar = true;
            }
        } else {
            const outOfSidebar = x < width - panels.sidebar.width * (1 - panels.sidebar.offsetScale);
            // Show osd on hover
            const showOsd = outOfSidebar && inRightPanel(panels.osdWrapper, x, y);

            // Always update visibility based on hover if not in shortcut mode
            if (!osdShortcutActive) {
                screenState.osd = showOsd;
                root.panels.osd.hovered = showOsd;
            } else if (showOsd) {
                // If hovering over OSD area while in shortcut mode, transition to hover control
                osdShortcutActive = false;
                root.panels.osd.hovered = true;
            }

            // Show/hide session on drag
            if (pressed && outOfSidebar && inRightPanel(panels.sessionWrapper, dragStart.x, dragStart.y) && withinPanelHeight(panels.sessionWrapper, x, y)) {
                if (dragX < -Config.session.dragThreshold)
                    screenState.session = true;
                else if (dragX > Config.session.dragThreshold)
                    screenState.session = false;
            }

            // Show/hide sidebar on hover
            if (Config.sidebar.showOnHover && !pressed) {
                const sidebarTriggerY = Math.max(Config.sidebar.minHoverThreshold, panels.notifications.y + panels.notifications.height + borderThickness);
                const showSidebarHover = x > Math.min(width - Config.border.minThickness, geometry.insetLeft(borderThickness) + panels.sidebar.x) && y <= sidebarTriggerY;
                if (showSidebarHover && !screenState.sidebar) {
                    screenState.sidebar = true;
                } else {
                    const inSidebarArea = inRightPanel(panels.sidebar, x, y) || inRightPanel(panels.sessionWrapper, x, y);
                    if (!inSidebarArea)
                        screenState.sidebar = false;
                }
            }

            // Hide sidebar on drag
            if (pressed && inRightPanel(panels.sidebar, dragStart.x, 0) && dragX > Config.sidebar.dragThreshold)
                screenState.sidebar = false;
        }

        // Show launcher on hover, or show/hide on drag if hover is disabled
        if (Config.launcher.showOnHover) {
            if (!screenState.launcher && inBottomPanel(panels.launcher, x, y) && !(geometry.barOnBottom && geometry.barContains(x, y)))
                screenState.launcher = true;
        } else if (pressed && inBottomPanel(panels.launcher, dragStart.x, dragStart.y) && !(geometry.barOnBottom && geometry.barContains(dragStart.x, dragStart.y)) && withinPanelWidth(panels.launcher, x, y)) {
            if (dragY < -Config.launcher.dragThreshold)
                screenState.launcher = true;
            else if (dragY > Config.launcher.dragThreshold)
                screenState.launcher = false;
        }

        // Show dashboard on hover
        const showDashboard = Config.dashboard.showOnHover && inDashboardArea(x, y);

        // Always update visibility based on hover if not in shortcut mode
        if (!dashboardShortcutActive) {
            screenState.dashboard = showDashboard;
        } else if (showDashboard) {
            // If hovering over dashboard area while in shortcut mode, transition to hover control
            dashboardShortcutActive = false;
        }

        // Show/hide dashboard on drag (for touchscreen devices)
        if (pressed && inDashboardArea(dragStart.x, dragStart.y) && (geometry.dashboardOnLeft ? withinPanelHeight(panels.dashboard, x, y) : withinPanelWidth(panels.dashboard, x, y))) {
            const dashDrag = geometry.dashboardOnLeft ? dragX : dragY;
            if (dashDrag > Config.dashboard.dragThreshold)
                screenState.dashboard = true;
            else if (dashDrag < -Config.dashboard.dragThreshold)
                screenState.dashboard = false;
        }

        // Show utilities on hover; on a bottom bar it rides the power entry instead of an edge zone
        let showUtilities;
        if (geometry.barOnBottom) {
            const entry = geometry.barContains(x, y) ? bar.entryAt(geometry.axisPos(x, y)) : "";
            showUtilities = entry === "power" || (screenState.utilities && !entry && inBottomPanel(panels.utilities, x, y, true));
        } else {
            showUtilities = inBottomPanel(panels.utilities, x, y, true);
        }

        // Always update visibility based on hover if not in shortcut mode
        if (!utilitiesShortcutActive) {
            screenState.utilities = showUtilities;
        } else if (showUtilities) {
            // If hovering over utilities area while in shortcut mode, transition to hover control
            utilitiesShortcutActive = false;
        }

        // Show popouts on hover
        if (geometry.barContains(x, y)) {
            bar.checkPopout(geometry.axisPos(x, y));
        } else if ((!popouts.currentName.startsWith("traymenu") || ((popouts.current as StackView)?.depth ?? 0) <= 1) && !inPopoutArea(x, y)) {
            popouts.hasCurrent = false;
            bar.closeTray();
        }
    }

    // Keep the dashboard open if a tab switch resizes it away from the cursor
    Connections {
        function onWidthChanged() {
            if (root.screenState.dashboard && !root.dashboardShortcutActive && !root.inDashboardArea(root.mouseX, root.mouseY))
                root.dashboardShortcutActive = true;
        }

        function onHeightChanged() {
            if (root.screenState.dashboard && !root.dashboardShortcutActive && !root.inDashboardArea(root.mouseX, root.mouseY))
                root.dashboardShortcutActive = true;
        }

        target: root.panels.dashboard
    }

    // Monitor individual visibility changes
    Connections {
        function onLauncherChanged() {
            // If launcher is hidden, clear shortcut flags for dashboard and OSD
            if (!root.screenState.launcher) {
                root.dashboardShortcutActive = false;
                root.osdShortcutActive = false;
                root.utilitiesShortcutActive = false;

                // Also hide dashboard and OSD if they're not being hovered
                const inDashboardArea = root.inDashboardArea(root.mouseX, root.mouseY);
                const inOsdArea = root.inRightPanel(root.panels.osdWrapper, root.mouseX, root.mouseY);

                if (!inDashboardArea) {
                    root.screenState.dashboard = false;
                }
                if (!inOsdArea) {
                    root.screenState.osd = false;
                    root.panels.osd.hovered = false;
                }
            }
        }

        function onDashboardChanged() {
            if (root.screenState.dashboard) {
                // Dashboard became visible, immediately check if this should be shortcut mode
                const inDashboardArea = root.inDashboardArea(root.mouseX, root.mouseY);
                if (!inDashboardArea) {
                    root.dashboardShortcutActive = true;
                }
            } else {
                // Dashboard hidden, clear shortcut flag
                root.dashboardShortcutActive = false;
            }
        }

        function onOsdChanged() {
            if (root.screenState.osd) {
                // OSD became visible, immediately check if this should be shortcut mode
                const inOsdArea = root.inRightPanel(root.panels.osdWrapper, root.mouseX, root.mouseY);
                if (!inOsdArea) {
                    root.osdShortcutActive = true;
                }
            } else {
                // OSD hidden, clear shortcut flag
                root.osdShortcutActive = false;
            }
        }

        function onUtilitiesChanged() {
            if (root.screenState.utilities) {
                // Utilities became visible, immediately check if this should be shortcut mode
                const inUtilitiesArea = root.inBottomPanel(root.panels.utilities, root.mouseX, root.mouseY);
                if (!inUtilitiesArea) {
                    root.utilitiesShortcutActive = true;
                }
            } else {
                // Utilities hidden, clear shortcut flag
                root.utilitiesShortcutActive = false;
            }
        }

        target: root.screenState
    }
}

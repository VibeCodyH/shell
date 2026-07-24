pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.components
import qs.modules.bar.popouts // Need to import this module so the Wrapper type is the same as others

Item {
    id: root

    required property ShellScreen screen
    required property string position
    required property real borderThickness

    readonly property alias content: content
    readonly property bool horizontal: position !== "left"
    property real offsetScale: {
        if (content.hasCurrent)
            return 0;
        if (position === "top")
            return y > 0 ? 0 : 1;
        if (position === "bottom")
            return content.isDetached ? 0 : 1;
        return x > 0 ? 0 : 1;
    }

    // Anchored, not y-bound: a Behavior-lagged y would dip the clip area into the bar while height animates
    anchors.bottom: position === "bottom" && !content.isDetached ? parent.bottom : undefined

    visible: width > 0 && height > 0
    clip: true

    implicitWidth: horizontal ? content.implicitWidth : content.implicitWidth * (1 - offsetScale)
    implicitHeight: horizontal ? content.implicitHeight * (1 - offsetScale) : content.implicitHeight

    // Where the popout is headed, before the Behaviors below lag it there. Bindings that need to
    // reason about the popout's real place — hover containment above all — must use these rather
    // than the animated x/y, which spend the whole open transition somewhere the popout is not.
    readonly property real targetX: {
        if (content.isDetached)
            return (parent.width - content.nonAnimWidth) / 2;
        if (!horizontal)
            return 0;

        const off = content.currentCenter - borderThickness - content.nonAnimWidth / 2;
        const diff = parent.width - Math.floor(off + content.nonAnimWidth);
        if (diff < 0)
            return off + diff;
        return Math.max(off, 0);
    }
    readonly property real targetY: {
        if (content.isDetached)
            return (parent.height - content.nonAnimHeight) / 2;
        if (horizontal)
            return 0;

        const off = content.currentCenter - borderThickness - content.nonAnimHeight / 2;
        const diff = parent.height - Math.floor(off + content.nonAnimHeight);
        if (diff < 0)
            return off + diff;
        return Math.max(off, 0);
    }

    // The rect the popout is settling into, in parent coordinates. The window's input mask
    // (modules/drawers/Regions.qml) is cut from this rather than from the animated geometry: an
    // interactive hole that lags what is drawn lets the pointer fall straight through the visible
    // popout to the window underneath. While closing there is nothing to settle into, so these
    // track the live geometry and the hole shrinks with it.
    readonly property bool opening: content.hasCurrent || content.isDetached
    readonly property real settledWidth: opening ? content.nonAnimWidth : width
    readonly property real settledHeight: opening ? content.nonAnimHeight : height
    readonly property real settledX: opening ? targetX : x
    readonly property real settledY: {
        if (!opening)
            return y;
        if (position === "bottom")
            return parent.height - settledHeight;
        if (position === "top")
            return 0;
        return targetY;
    }

    x: targetX
    y: targetY

    Behavior on offsetScale {
        Anim {}
    }

    Behavior on x {
        enabled: !root.horizontal || root.offsetScale < 1

        Anim {
            duration: content.animLength
            easing: content.animCurve
        }
    }

    Behavior on y {
        enabled: root.horizontal || root.offsetScale < 1

        Anim {
            duration: content.animLength
            easing: content.animCurve
        }
    }

    Wrapper {
        id: content

        screen: root.screen
        offsetScale: root.offsetScale

        anchors.verticalCenter: root.horizontal ? undefined : parent.verticalCenter
        anchors.horizontalCenter: root.horizontal ? parent.horizontalCenter : undefined
        anchors.left: root.horizontal ? undefined : parent.left
        anchors.top: root.position === "top" ? parent.top : undefined
        anchors.bottom: root.position === "bottom" ? parent.bottom : undefined
        anchors.leftMargin: (-implicitWidth - 5) * root.offsetScale
        anchors.topMargin: (-implicitHeight - 5) * root.offsetScale
        anchors.bottomMargin: (-implicitHeight - 5) * root.offsetScale
    }
}

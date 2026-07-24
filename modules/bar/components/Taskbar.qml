pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property ShellScreen screen
    required property bool horizontal

    readonly property alias layout: layout

    // Ordering + persistence live in the TaskbarOrder singleton so every monitor's bar — and the
    // hover-preview popouts (see modules/bar/popouts/Content.qml) — share one source of truth.
    readonly property var orderedToplevels: TaskbarOrder.sorted(Hypr.toplevels.values)

    function addressAt(index: int): string {
        return root.orderedToplevels[index]?.lastIpcObject?.address ?? "";
    }

    // Arithmetic slot from a layout-local point (items are uniform, so this beats childAt:
    // no dead zones in the spacing, and it ignores the lifted item's scale/overlap mid-drag).
    function indexAtPoint(x: real, y: real): int {
        const n = items.count;
        if (n <= 0)
            return -1;
        const first = items.itemAt(0);
        if (!first)
            return -1;
        const stride = (root.horizontal ? first.width : first.height) + layout.spacing;
        const pos = root.horizontal ? x : y;
        return Math.max(0, Math.min(Math.floor(pos / stride), n - 1));
    }

    function moveItem(address: string, toIndex: int): void {
        const entries = root.orderedToplevels.map(t => ({
                    address: t?.lastIpcObject?.address ?? "",
                    appClass: t?.lastIpcObject?.class ?? ""
                })).filter(e => e.address);
        TaskbarOrder.moveItem(entries, address, toIndex);
    }

    clip: true
    implicitWidth: horizontal ? layout.implicitWidth : Tokens.sizes.bar.innerWidth
    implicitHeight: horizontal ? Tokens.sizes.bar.innerWidth : layout.implicitHeight

    Grid {
        id: layout

        anchors.centerIn: parent
        columns: root.horizontal ? Math.max(1, items.count) : 1
        spacing: Tokens.spacing.extraSmall

        move: Transition {
            Anim {
                properties: "x,y"
                type: Anim.DefaultSpatial
            }
        }

        Repeater {
            id: items

            model: ScriptModel {
                values: root.orderedToplevels
            }

            TaskbarItem {}
        }
    }

    // One drag handler on the stable parent (not per-item): reordering the model during a
    // drag can recreate the dragged delegate, which would kill a per-item handler's grab.
    // Living here, the grab survives every reorder. target:null so it never moves the bar.
    DragHandler {
        id: dragHandler

        target: null

        onActiveChanged: {
            if (active) {
                const p = root.mapToItem(layout, centroid.position.x, centroid.position.y);
                TaskbarOrder.draggingAddress = root.addressAt(root.indexAtPoint(p.x, p.y));
            } else {
                TaskbarOrder.draggingAddress = "";
            }
        }

        onCentroidChanged: {
            if (!active || !TaskbarOrder.draggingAddress)
                return;

            const p = root.mapToItem(layout, centroid.position.x, centroid.position.y);
            root.moveItem(TaskbarOrder.draggingAddress, root.indexAtPoint(p.x, p.y));
        }
    }
}

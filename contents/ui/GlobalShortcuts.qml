/*
    SPDX-FileCopyrightText: 2026 Matt Anis
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

import org.kde.plasma.plasmoid
import org.kde.plasma.workspace.dbus as DBus

import "code/GlobalShortcuts.js" as GlobalShortcuts

// Registers "Super + 1" … "Super + 9" with KGlobalAccel and forwards presses to
// the task at the matching position. Only one dock instance reacts at a time so
// that pressing a shortcut does not activate the same app in every dock.
QtObject {
    id: root

    required property var tasksRoot
    required property int appletId

    property bool ownsShortcuts: false
    readonly property bool shortcutsEnabled: Plasmoid.configuration.shortcutsEnabled !== false

    function claimOwnership(): void {
        if (GlobalShortcuts.ownerId === -1 || GlobalShortcuts.ownerId === appletId) {
            GlobalShortcuts.ownerId = appletId;
            ownsShortcuts = true;
            GlobalShortcuts.setShortcutsActive(DBus.SessionBus, shortcutsEnabled);
        } else {
            ownsShortcuts = false;
        }
    }

    onShortcutsEnabledChanged: {
        if (root.ownsShortcuts) {
            GlobalShortcuts.setShortcutsActive(DBus.SessionBus, root.shortcutsEnabled);
        }
    }

    Component.onCompleted: {
        for (let i = 0; i < GlobalShortcuts.shortcutCount; ++i) {
            const actionFriendly = typeof i18nc === "function"
                ? i18nc("@action", "Activate Pinned App %1", i + 1)
                : "Activate Pinned App " + (i + 1);
            GlobalShortcuts.register(DBus.SessionBus, i, actionFriendly);
        }
        claimOwnership();
    }

    Component.onDestruction: {
        if (GlobalShortcuts.ownerId === appletId) {
            GlobalShortcuts.ownerId = -1;
        }
    }

    // Take over if the dock that owned the shortcuts was removed.
    property Timer ownershipTimer: Timer {
        interval: 2000
        repeat: true
        running: !root.ownsShortcuts
        onTriggered: root.claimOwnership()
    }

    property DBus.SignalWatcher shortcutWatcher: DBus.SignalWatcher {
        enabled: root.ownsShortcuts && root.shortcutsEnabled
        busType: DBus.BusType.Session
        service: GlobalShortcuts.SERVICE
        path: GlobalShortcuts.COMPONENT_PATH
        iface: GlobalShortcuts.COMPONENT_INTERFACE

        function dbusglobalShortcutPressed(componentUnique, actionUnique, timestamp) {
            const index = GlobalShortcuts.actionIndex(actionUnique);
            if (index !== -1) {
                root.tasksRoot.activateTaskAtIndex(index);
            }
        }

        function dbusglobalShortcutReleased(componentUnique, actionUnique, timestamp) {}
    }

    // The stock task manager actions are disabled at registration time, but
    // if another task manager re-enables them, KGlobalAccel may route the key
    // to them instead of to our actions.
    property DBus.SignalWatcher stockShortcutWatcher: DBus.SignalWatcher {
        enabled: root.ownsShortcuts && root.shortcutsEnabled
        busType: DBus.BusType.Session
        service: GlobalShortcuts.SERVICE
        path: GlobalShortcuts.STOCK_COMPONENT_PATH
        iface: GlobalShortcuts.COMPONENT_INTERFACE

        function dbusglobalShortcutPressed(componentUnique, actionUnique, timestamp) {
            const index = GlobalShortcuts.stockActionIndex(actionUnique);
            if (index !== -1) {
                root.tasksRoot.activateTaskAtIndex(index);
            }
        }

        function dbusglobalShortcutReleased(componentUnique, actionUnique, timestamp) {}
    }
}

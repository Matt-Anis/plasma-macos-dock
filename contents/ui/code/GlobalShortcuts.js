/*
    SPDX-FileCopyrightText: 2026 Matt Anis
    SPDX-License-Identifier: GPL-2.0-or-later
*/

.pragma library

// KGlobalAccel exposes its registry over D-Bus. Upstream task managers register
// "Super + 1" … "Super + 9" from their C++ backend; this applet is pure QML,
// so the shortcuts are registered directly through the same D-Bus API.
const SERVICE = "org.kde.kglobalaccel";
const OBJECT_PATH = "/kglobalaccel";
const INTERFACE = "org.kde.KGlobalAccel";

const COMPONENT_UNIQUE = "macosdock";
const COMPONENT_FRIENDLY = "macOS Dock";
const COMPONENT_PATH = "/component/" + COMPONENT_UNIQUE;
const COMPONENT_INTERFACE = "org.kde.kglobalaccel.Component";

// Plasma's stock task manager registers the same "Super + 1" … "Super + 9"
// shortcuts under the "plasmashell" component. When both are present
// KGlobalAccel only triggers the action with the oldest serial, which is
// usually the stock one, so the dock's own shortcut never fires. Disable the
// stock actions for this session (this does not change the saved shortcut
// configuration) and, as a fallback, also listen for their signals in case
// another task manager re-enables them.
const STOCK_COMPONENT_UNIQUE = "plasmashell";
const STOCK_COMPONENT_PATH = "/component/" + STOCK_COMPONENT_UNIQUE;
const STOCK_COMPONENT_FRIENDLY = "plasmashell";
const STOCK_ACTION_PREFIX = "activate task manager entry ";

const ACTION_PREFIX = "activate-task-";
const META_MODIFIER = 0x10000000; // Qt.MetaModifier
const KEY_1 = 0x31; // Qt.Key_1
const SET_PRESENT = 2; // KGlobalAccel::SetPresent

const shortcutCount = 9;

// The id of the applet instance that listens for the shortcuts. All applets
// share one QQmlEngine, so this is shared between dock instances and avoids
// launching an app once per dock when several docks are present.
var ownerId = -1;

function actionId(index, actionFriendly) {
    return [
        COMPONENT_UNIQUE,
        ACTION_PREFIX + String(index + 1),
        COMPONENT_FRIENDLY,
        actionFriendly,
    ];
}

function actionIndex(actionUnique) {
    const action = String(actionUnique);
    if (!action.startsWith(ACTION_PREFIX)) {
        return -1;
    }

    const number = Number(action.substring(ACTION_PREFIX.length));
    if (!Number.isInteger(number) || number < 1 || number > shortcutCount) {
        return -1;
    }

    return number - 1;
}

function stockActionIndex(actionUnique) {
    const action = String(actionUnique);
    if (!action.startsWith(STOCK_ACTION_PREFIX)) {
        return -1;
    }

    const number = Number(action.substring(STOCK_ACTION_PREFIX.length));
    if (!Number.isInteger(number) || number < 1 || number > shortcutCount) {
        return -1;
    }

    return number - 1;
}

function stockActionId(index) {
    const number = index + 1;
    return [
        STOCK_COMPONENT_UNIQUE,
        STOCK_ACTION_PREFIX + String(number),
        STOCK_COMPONENT_FRIENDLY,
        "Activate Task Manager Entry " + String(number),
    ];
}

// `setInactive` only marks the action as not present in kglobalacceld; it is
// not written to kglobalshortcutsrc, so the user's stock shortcut settings are
// left untouched.
function disableStockShortcut(bus, index) {
    bus.asyncCall({
        "service": SERVICE,
        "path": OBJECT_PATH,
        "iface": INTERFACE,
        "member": "setInactive",
        "signature": "(as)",
        "arguments": [stockActionId(index)],
    }, () => {}, () => {});
}

// Bumped whenever the enabled state changes so a pending async reply from an
// earlier state cannot re-enable an action after the user disabled it.
var activeStateGeneration = 0;

function setShortcutActive(bus, index, active, generation) {
    const id = actionId(index, "Activate Pinned App " + String(index + 1));

    if (!active) {
        bus.asyncCall({
            "service": SERVICE,
            "path": OBJECT_PATH,
            "iface": INTERFACE,
            "member": "setInactive",
            "signature": "(as)",
            "arguments": [id],
        }, () => {}, () => {});
        return;
    }

    // Read the keys currently stored by KGlobalAccel instead of writing the
    // defaults, so re-enabling the shortcuts preserves any key the user
    // configured in System Settings.
    bus.asyncCall({
        "service": SERVICE,
        "path": OBJECT_PATH,
        "iface": INTERFACE,
        "member": "shortcut",
        "signature": "(as)",
        "arguments": [id],
    }, (reply) => {
        if (generation !== activeStateGeneration || !reply || !reply.isValid || reply.isError) {
            return;
        }

        const keys = Array.prototype.map.call(reply.value, key => {
            return typeof key === "number" ? key : key.value;
        });

        bus.asyncCall({
            "service": SERVICE,
            "path": OBJECT_PATH,
            "iface": INTERFACE,
            "member": "setShortcut",
            "signature": "(asaiu)",
            "arguments": [id, keys, SET_PRESENT],
        }, () => {}, () => {});

        disableStockShortcut(bus, index);
    }, () => {});
}

function setShortcutsActive(bus, active) {
    const generation = ++activeStateGeneration;
    for (let i = 0; i < shortcutCount; ++i) {
        setShortcutActive(bus, i, active, generation);
    }
}

function keySequence(index) {
    return META_MODIFIER | (KEY_1 + index);
}

function register(bus, index, actionFriendly) {
    const id = actionId(index, actionFriendly);

    bus.asyncCall({
        "service": SERVICE,
        "path": OBJECT_PATH,
        "iface": INTERFACE,
        "member": "doRegister",
        "signature": "(as)",
        "arguments": [id],
    }, () => {}, () => {});

    bus.asyncCall({
        "service": SERVICE,
        "path": OBJECT_PATH,
        "iface": INTERFACE,
        "member": "setShortcut",
        "signature": "(asaiu)",
        "arguments": [id, [keySequence(index)], SET_PRESENT],
    }, () => {}, () => {});

    disableStockShortcut(bus, index);
}

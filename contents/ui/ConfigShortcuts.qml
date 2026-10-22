/*
    SPDX-FileCopyrightText: 2026 Matt Anis
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

KCMUtils.SimpleKCM {
    id: root

    property alias cfg_shortcutsEnabled: shortcutsEnabled.checked
    property alias cfg_shortcutsPinnedOnly: shortcutsPinnedOnly.checked
    property alias cfg_shortcutsLaunchMissing: shortcutsLaunchMissing.checked

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18nc("@title:group", "Pinned App Shortcuts")
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: true
            type: Kirigami.MessageType.Information
            text: i18nc("@info", "Super+1 through Super+9 launch or activate the task at the matching dock position. These shortcuts work globally, even when the dock is hidden.")
        }

        QQC2.Button {
            text: i18nc("@action:button", "Configure Shortcut Keys…")
            icon.name: "preferences-desktop-keyboard-shortcuts"
            onClicked: KCMUtils.KCMLauncher.openSystemSettings("kcm_keys")
        }

        QQC2.CheckBox {
            id: shortcutsEnabled
            checked: Plasmoid.configuration.shortcutsEnabled !== false
            text: i18nc("@option:check", "Enable Super+1–9 shortcuts")
        }

        QQC2.CheckBox {
            id: shortcutsPinnedOnly
            checked: Plasmoid.configuration.shortcutsPinnedOnly !== false
            enabled: shortcutsEnabled.checked
            text: i18nc("@option:check", "Only activate pinned apps")
        }

        QQC2.Label {
            Layout.fillWidth: true
            visible: shortcutsEnabled.checked
            text: i18nc("@info", "When unchecked, shortcuts can also activate running apps shown after the pinned section.")
            wrapMode: Text.WordWrap
            font: Kirigami.Theme.smallFont
            opacity: 0.7
        }

        QQC2.CheckBox {
            id: shortcutsLaunchMissing
            checked: Plasmoid.configuration.shortcutsLaunchMissing !== false
            enabled: shortcutsEnabled.checked
            text: i18nc("@option:check", "Launch apps that are not running")
        }

        QQC2.Label {
            Layout.fillWidth: true
            visible: shortcutsEnabled.checked
            text: i18nc("@info", "When unchecked, shortcuts only switch to apps that are already running.")
            wrapMode: Text.WordWrap
            font: Kirigami.Theme.smallFont
            opacity: 0.7
        }
    }
}

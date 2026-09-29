/*
    SPDX-FileCopyrightText: 2024 Matt Anis
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root

    property real radius: Math.min(width, height) / 3
    property int backgroundType: 0 // 0 = Solid, 1 = Transparent, 2 = SystemBlur, 3 = LiquidGlass
    property color customBackgroundColor: "#202024"
    property int customBorderWidth: 1
    property color customBorderColor: "#38ffffff"
    property bool isVertical: false

    property real blurOpacity: 0.35
    property real blurSaturation: 1.3
    property real blurContrast: 1.0
    property real blurBrightness: 1.0

    // C++ KWin blur region loader
    Loader {
        id: blurBridgeLoader
        anchors.fill: parent
        active: root.backgroundType === 2 || root.backgroundType === 3
        asynchronous: false
        source: "BlurAreaBridge.qml"
        property real radius: root.radius
        property real saturation: root.blurSaturation
        property real contrast: root.blurContrast
        property real intensity: root.blurBrightness

        onStatusChanged: {
            if (status === Loader.Error) {
                console.warn("[macOS Dock] com.github.mattanis.macosdock.blur C++ plugin not loaded, running without KWin blur.");
            }
        }
    }

    // ==========================================
    // MODE 0: SOLID BACKGROUND
    // ==========================================
    Rectangle {
        id: solidBackground
        visible: root.backgroundType === 0
        anchors.fill: parent
        radius: root.radius
        color: root.customBackgroundColor
        border.color: root.customBorderWidth > 0 ? root.customBorderColor : "transparent"
        border.width: root.customBorderWidth
    }

    // ==========================================
    // MODE 2: SYSTEM BLUR (Translucent Tint + KWin Blur)
    // ==========================================
    Rectangle {
        id: systemBlurBackground
        visible: root.backgroundType === 2
        anchors.fill: parent
        radius: root.radius
        color: Qt.rgba(root.customBackgroundColor.r, root.customBackgroundColor.g, root.customBackgroundColor.b, root.blurOpacity)
        border.color: root.customBorderWidth > 0 ? root.customBorderColor : "transparent"
        border.width: root.customBorderWidth
    }

    // ==========================================
    // MODE 3: LIQUID GLASS
    // ==========================================
    Item {
        id: liquidGlassContainer
        visible: root.backgroundType === 3
        anchors.fill: parent

        // Single clean glass base rectangle with crisp border
        Rectangle {
            id: glassBase
            anchors.fill: parent
            radius: root.radius
            color: {
                const isDark = Kirigami.Theme.backgroundColor.hslLightness < 0.5;
                return isDark
                    ? Qt.rgba(0.12, 0.12, 0.15, root.blurOpacity)
                    : Qt.rgba(0.96, 0.97, 1.0, root.blurOpacity);
            }
            border.color: root.customBorderWidth > 0 ? root.customBorderColor : "transparent"
            border.width: root.customBorderWidth

            // Internal gloss sheen inset safely inside the border
            Rectangle {
                anchors.fill: parent
                anchors.margins: Math.max(0, root.customBorderWidth)
                radius: Math.max(0, root.radius - root.customBorderWidth)
                color: "transparent"
                gradient: Gradient {
                    orientation: root.isVertical ? Gradient.Horizontal : Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.16) }
                    GradientStop { position: 0.35; color: Qt.rgba(1, 1, 1, 0.04) }
                    GradientStop { position: 0.75; color: Qt.rgba(1, 1, 1, 0.01) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.06) }
                }
            }
        }
    }
}

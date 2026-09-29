/*
    SPDX-FileCopyrightText: 2024 Matt Anis
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import com.github.mattanis.macosdock.blur as BlurPlugin

BlurPlugin.DockBlurArea {
    id: blurArea
    anchors.fill: parent
    blurEnabled: true
    cornerRadius: parent && parent.radius !== undefined ? parent.radius : 0
    saturation: parent && parent.saturation !== undefined ? parent.saturation : 1.0
    contrast: parent && parent.contrast !== undefined ? parent.contrast : 1.0
    intensity: parent && parent.intensity !== undefined ? parent.intensity : 1.0
}

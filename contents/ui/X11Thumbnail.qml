/*
    SPDX-FileCopyrightText: 2024 Matt Anis
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import org.kde.plasma.core as PlasmaCore

PlasmaCore.WindowThumbnail {
    id: windowThumbnail
    anchors.fill: parent
    winId: thumbnailSourceItem.winId
}

/*
    SPDX-FileCopyrightText: 2024 Matt Anis
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "blurplugin.h"
#include "dockbluritem.h"

#include <QtQml>

void BlurPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<DockBlurItem>(uri, 1, 0, "DockBlurArea");
}

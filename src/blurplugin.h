/*
    SPDX-FileCopyrightText: 2024 Matt Anis
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <QQmlExtensionPlugin>

class BlurPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    using QQmlExtensionPlugin::QQmlExtensionPlugin;
    void registerTypes(const char *uri) override;
};

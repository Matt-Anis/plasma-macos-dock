/*
    SPDX-FileCopyrightText: 2024 Matt Anis
    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "dockbluritem.h"

#include <KWindowEffects>
#include <QPainterPath>
#include <QQuickWindow>

DockBlurItem::DockBlurItem(QQuickItem *parent)
    : QQuickItem(parent)
{
    setFlag(ItemHasContents, false);
}

DockBlurItem::~DockBlurItem()
{
    clearBlurRegion();
}

bool DockBlurItem::blurEnabled() const
{
    return m_blurEnabled;
}

void DockBlurItem::setBlurEnabled(bool enabled)
{
    if (m_blurEnabled != enabled) {
        m_blurEnabled = enabled;
        Q_EMIT blurEnabledChanged();
        updateBlurRegion();
    }
}

qreal DockBlurItem::cornerRadius() const
{
    return m_cornerRadius;
}

void DockBlurItem::setCornerRadius(qreal radius)
{
    if (!qFuzzyCompare(m_cornerRadius, radius)) {
        m_cornerRadius = radius;
        Q_EMIT cornerRadiusChanged();
        m_lastAppliedRect = QRect(); // force region recalculation
        updateBlurRegion();
    }
}

qreal DockBlurItem::saturation() const
{
    return m_saturation;
}

void DockBlurItem::setSaturation(qreal val)
{
    if (!qFuzzyCompare(m_saturation, val)) {
        m_saturation = val;
        Q_EMIT saturationChanged();
        m_lastAppliedRect = QRect();
        updateBlurRegion();
    }
}

qreal DockBlurItem::contrast() const
{
    return m_contrast;
}

void DockBlurItem::setContrast(qreal val)
{
    if (!qFuzzyCompare(m_contrast, val)) {
        m_contrast = val;
        Q_EMIT contrastChanged();
        m_lastAppliedRect = QRect();
        updateBlurRegion();
    }
}

qreal DockBlurItem::intensity() const
{
    return m_intensity;
}

void DockBlurItem::setIntensity(qreal val)
{
    if (!qFuzzyCompare(m_intensity, val)) {
        m_intensity = val;
        Q_EMIT intensityChanged();
        m_lastAppliedRect = QRect();
        updateBlurRegion();
    }
}

void DockBlurItem::itemChange(ItemChange change, const ItemChangeData &value)
{
    if (change == ItemSceneChange) {
        if (m_trackedWindow) {
            disconnect(m_trackedWindow.data(), nullptr, this, nullptr);
            clearBlurRegion();
        }
        m_trackedWindow = window();
        if (m_trackedWindow) {
            connect(m_trackedWindow.data(), &QWindow::visibleChanged, this, &DockBlurItem::updateBlurRegion);
            connect(m_trackedWindow.data(), &QQuickWindow::beforeRendering, this, &DockBlurItem::updateBlurRegion);
            updateBlurRegion();
        }
    } else if (change == ItemVisibleHasChanged) {
        updateBlurRegion();
    }
    QQuickItem::itemChange(change, value);
}

void DockBlurItem::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    QQuickItem::geometryChange(newGeometry, oldGeometry);
    updateBlurRegion();
}

void DockBlurItem::clearBlurRegion()
{
    if (m_trackedWindow) {
        KWindowEffects::enableBlurBehind(m_trackedWindow.data(), false);
        KWindowEffects::enableBackgroundContrast(m_trackedWindow.data(), false);
    }
    m_lastAppliedRect = QRect();
}

void DockBlurItem::updateBlurRegion()
{
    if (!m_trackedWindow || !isVisible() || !m_blurEnabled || width() <= 0 || height() <= 0) {
        if (!m_lastAppliedRect.isEmpty()) {
            clearBlurRegion();
        }
        return;
    }

    const QRectF mappedRectF = mapRectToScene(boundingRect());
    const QRect mappedRect = mappedRectF.toAlignedRect();

    if (mappedRect == m_lastAppliedRect) {
        return;
    }

    m_lastAppliedRect = mappedRect;

    QRegion blurRegion;
    if (m_cornerRadius > 0.0) {
        QPainterPath path;
        path.addRoundedRect(QRectF(mappedRect), m_cornerRadius, m_cornerRadius);
        blurRegion = QRegion(path.toFillPolygon().toPolygon());
    } else {
        blurRegion = QRegion(mappedRect);
    }

    KWindowEffects::enableBlurBehind(m_trackedWindow.data(), true, blurRegion);
    KWindowEffects::enableBackgroundContrast(m_trackedWindow.data(), true, m_contrast, m_intensity, m_saturation, blurRegion);
}

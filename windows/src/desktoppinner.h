// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <QList>
#include <QObject>
#include <QPointer>
#include <QQmlEngine>
#include <QWindow>

// Keeps the countdown windows visible when the user shows the desktop
// (Win+D or the end of the taskbar), which otherwise hides them like any
// other window. While the desktop is in front with no application window
// over it, the countdowns are raised above it without taking focus; when
// another application becomes active they go back to the bottom.
//
// This depends on how Windows arranges the desktop windows, which changed
// in Windows 11 24H2, so all of it lives here. On other systems it does
// nothing.
class DesktopPinner : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit DesktopPinner(QObject *parent = nullptr);
    ~DesktopPinner() override;

    Q_INVOKABLE void pin(QWindow *window);

private Q_SLOTS:
    void updateZOrder();

private:
    QList<QPointer<QWindow>> m_windows;
    bool m_raised = false;
};

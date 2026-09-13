// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <QObject>
#include <QQmlEngine>

// Starts the app when the user signs in, through the per-user Run key in
// the Windows registry. On other systems `supported` is false.
class Autostart : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(bool supported READ isSupported CONSTANT)
    Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)

public:
    explicit Autostart(QObject *parent = nullptr);

    bool isSupported() const;
    bool isEnabled() const;
    void setEnabled(bool enabled);

Q_SIGNALS:
    void enabledChanged();
};

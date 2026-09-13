// SPDX-License-Identifier: GPL-3.0-or-later

#include "autostart.h"

#include <QCoreApplication>
#include <QDir>
#include <QSettings>

namespace
{
// The installer's "start with Windows" option writes the same value.
const QString ValueName = QStringLiteral("TimeUntil");

#ifdef Q_OS_WIN
QSettings runKey()
{
    return QSettings(QStringLiteral("HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Run"), QSettings::NativeFormat);
}
#endif
} // namespace

Autostart::Autostart(QObject *parent)
    : QObject(parent)
{
}

bool Autostart::isSupported() const
{
#ifdef Q_OS_WIN
    return true;
#else
    return false;
#endif
}

bool Autostart::isEnabled() const
{
#ifdef Q_OS_WIN
    return runKey().contains(ValueName);
#else
    return false;
#endif
}

void Autostart::setEnabled(bool enabled)
{
#ifdef Q_OS_WIN
    if (enabled == isEnabled()) {
        return;
    }
    QSettings settings = runKey();
    if (enabled) {
        const QString path = QDir::toNativeSeparators(QCoreApplication::applicationFilePath());
        settings.setValue(ValueName, QLatin1Char('"') + path + QLatin1Char('"'));
    } else {
        settings.remove(ValueName);
    }
    Q_EMIT enabledChanged();
#else
    Q_UNUSED(enabled)
#endif
}

// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <QHash>
#include <QObject>
#include <QStringList>
#include <QVariant>

// Gives QML the i18n(), i18nc(), i18np() and i18ncp() functions that
// KLocalizedContext provides on Plasma, so the QML shared with the widget
// works unchanged. Translations come from the same po/*.po files, embedded
// under :/i18n. Only languages with the plural rule n != 1 are supported.
class LocalizedContext : public QObject
{
    Q_OBJECT

public:
    explicit LocalizedContext(QObject *parent = nullptr);

    // Loads the catalog of the first language in the list that has one.
    // English is the source language, so it stops there without loading.
    void loadTranslations(const QStringList &languages);

    Q_INVOKABLE QString i18n(const QString &message,
                             const QVariant &param1 = QVariant(),
                             const QVariant &param2 = QVariant(),
                             const QVariant &param3 = QVariant(),
                             const QVariant &param4 = QVariant(),
                             const QVariant &param5 = QVariant()) const;

    Q_INVOKABLE QString i18nc(const QString &context,
                              const QString &message,
                              const QVariant &param1 = QVariant(),
                              const QVariant &param2 = QVariant(),
                              const QVariant &param3 = QVariant(),
                              const QVariant &param4 = QVariant(),
                              const QVariant &param5 = QVariant()) const;

    // The first parameter is the number that selects the plural form.
    Q_INVOKABLE QString i18np(const QString &singular,
                              const QString &plural,
                              const QVariant &param1 = QVariant(),
                              const QVariant &param2 = QVariant(),
                              const QVariant &param3 = QVariant(),
                              const QVariant &param4 = QVariant(),
                              const QVariant &param5 = QVariant()) const;

    Q_INVOKABLE QString i18ncp(const QString &context,
                               const QString &singular,
                               const QString &plural,
                               const QVariant &param1 = QVariant(),
                               const QVariant &param2 = QVariant(),
                               const QVariant &param3 = QVariant(),
                               const QVariant &param4 = QVariant(),
                               const QVariant &param5 = QVariant()) const;

private:
    void parsePo(const QByteArray &data);
    QString translate(const QString &context, const QString &singular, const QString &plural, int count) const;

    // Key: msgid, or msgctxt + '\x04' + msgid as in gettext. Value: msgstr forms.
    QHash<QString, QStringList> m_catalog;
};

// SPDX-License-Identifier: GPL-3.0-or-later

#include "localizedcontext.h"

#include <QFile>

namespace
{

QString catalogKey(const QString &context, const QString &message)
{
    return context.isEmpty() ? message : context + QChar(0x04) + message;
}

// Returns the text between the first and last quote of a .po line, unescaped.
QString unquote(const QByteArray &line)
{
    const qsizetype first = line.indexOf('"');
    const qsizetype last = line.lastIndexOf('"');
    if (first < 0 || last <= first) {
        return {};
    }
    QByteArray result;
    result.reserve(last - first);
    for (qsizetype i = first + 1; i < last; ++i) {
        char c = line.at(i);
        if (c == '\\' && i + 1 < last) {
            c = line.at(++i);
            switch (c) {
            case 'n':
                c = '\n';
                break;
            case 't':
                c = '\t';
                break;
            default:
                break;
            }
        }
        result.append(c);
    }
    return QString::fromUtf8(result);
}

// Replaces %1..%9 in one pass, so substituted text is never expanded again.
QString substitute(const QString &text, const QVariantList &params)
{
    QString result;
    result.reserve(text.size());
    for (qsizetype i = 0; i < text.size(); ++i) {
        if (text.at(i) == QLatin1Char('%') && i + 1 < text.size()) {
            const int index = text.at(i + 1).digitValue() - 1;
            if (index >= 0 && index < params.size() && params.at(index).isValid()) {
                result += params.at(index).toString();
                ++i;
                continue;
            }
        }
        result += text.at(i);
    }
    return result;
}

} // namespace

LocalizedContext::LocalizedContext(QObject *parent)
    : QObject(parent)
{
}

void LocalizedContext::loadTranslations(const QStringList &languages)
{
    for (QString language : languages) {
        language.replace(QLatin1Char('-'), QLatin1Char('_'));
        const QString base = language.section(QLatin1Char('_'), 0, 0);
        if (base == QLatin1String("en")) {
            return;
        }
        for (const QString &name : {language, base}) {
            QFile file(QStringLiteral(":/i18n/%1.po").arg(name));
            if (file.open(QIODevice::ReadOnly)) {
                parsePo(file.readAll());
                return;
            }
        }
    }
}

void LocalizedContext::parsePo(const QByteArray &data)
{
    enum class Field { None, Context, Id, IdPlural, Str };

    QString context;
    QString id;
    QStringList forms;
    bool fuzzy = false;
    Field field = Field::None;
    qsizetype formIndex = 0;

    const auto finishEntry = [&] {
        const bool translated = std::any_of(forms.cbegin(), forms.cend(), [](const QString &form) {
            return !form.isEmpty();
        });
        if (!id.isEmpty() && !fuzzy && translated) {
            m_catalog.insert(catalogKey(context, id), forms);
        }
        context.clear();
        id.clear();
        forms.clear();
        fuzzy = false;
        field = Field::None;
    };

    const QList<QByteArray> lines = data.split('\n');
    for (const QByteArray &rawLine : lines) {
        const QByteArray line = rawLine.trimmed();
        if (line.isEmpty()) {
            continue;
        }
        if (line.startsWith('#')) {
            if (field == Field::Str) {
                finishEntry();
            }
            if (line.startsWith("#,") && line.contains("fuzzy")) {
                fuzzy = true;
            }
        } else if (line.startsWith("msgctxt ")) {
            if (field == Field::Str) {
                finishEntry();
            }
            context = unquote(line);
            field = Field::Context;
        } else if (line.startsWith("msgid_plural ")) {
            field = Field::IdPlural;
        } else if (line.startsWith("msgid ")) {
            if (field == Field::Str) {
                finishEntry();
            }
            id = unquote(line);
            field = Field::Id;
        } else if (line.startsWith("msgstr[")) {
            formIndex = line.mid(7, line.indexOf(']') - 7).toInt();
            while (forms.size() <= formIndex) {
                forms.append(QString());
            }
            forms[formIndex] = unquote(line);
            field = Field::Str;
        } else if (line.startsWith("msgstr ")) {
            forms = {unquote(line)};
            formIndex = 0;
            field = Field::Str;
        } else if (line.startsWith('"')) {
            // Continuation of the previous string.
            switch (field) {
            case Field::Context:
                context += unquote(line);
                break;
            case Field::Id:
                id += unquote(line);
                break;
            case Field::Str:
                forms[formIndex] += unquote(line);
                break;
            case Field::IdPlural:
            case Field::None:
                break;
            }
        }
    }
    if (field == Field::Str) {
        finishEntry();
    }
}

QString LocalizedContext::translate(const QString &context, const QString &singular, const QString &plural, int count) const
{
    const bool hasPlural = !plural.isNull();
    const qsizetype form = hasPlural && count != 1 ? 1 : 0;
    const auto it = m_catalog.constFind(catalogKey(context, singular));
    if (it != m_catalog.cend() && form < it->size() && !it->at(form).isEmpty()) {
        return it->at(form);
    }
    return form == 1 ? plural : singular;
}

QString LocalizedContext::i18n(const QString &message,
                               const QVariant &param1,
                               const QVariant &param2,
                               const QVariant &param3,
                               const QVariant &param4,
                               const QVariant &param5) const
{
    return substitute(translate(QString(), message, QString(), 0), {param1, param2, param3, param4, param5});
}

QString LocalizedContext::i18nc(const QString &context,
                                const QString &message,
                                const QVariant &param1,
                                const QVariant &param2,
                                const QVariant &param3,
                                const QVariant &param4,
                                const QVariant &param5) const
{
    return substitute(translate(context, message, QString(), 0), {param1, param2, param3, param4, param5});
}

QString LocalizedContext::i18np(const QString &singular,
                                const QString &plural,
                                const QVariant &param1,
                                const QVariant &param2,
                                const QVariant &param3,
                                const QVariant &param4,
                                const QVariant &param5) const
{
    return substitute(translate(QString(), singular, plural, param1.toInt()), {param1, param2, param3, param4, param5});
}

QString LocalizedContext::i18ncp(const QString &context,
                                 const QString &singular,
                                 const QString &plural,
                                 const QVariant &param1,
                                 const QVariant &param2,
                                 const QVariant &param3,
                                 const QVariant &param4,
                                 const QVariant &param5) const
{
    return substitute(translate(context, singular, plural, param1.toInt()), {param1, param2, param3, param4, param5});
}

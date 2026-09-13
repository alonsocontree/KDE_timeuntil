// SPDX-License-Identifier: GPL-3.0-or-later

#include "eventstore.h"

#include <QDateTime>
#include <QSettings>
#include <QUuid>

namespace
{
const QString OrderKey = QStringLiteral("events/order");

QString groupFor(const QString &eventId)
{
    return QStringLiteral("events/") + eventId;
}
} // namespace

EventStore::EventStore(QObject *parent)
    : QAbstractListModel(parent)
{
    Q_ASSERT(!s_instance);
    s_instance = this;
    load();
    if (m_events.isEmpty()) {
        addEvent();
    }
}

EventStore::~EventStore()
{
    s_instance = nullptr;
}

EventStore *EventStore::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(qmlEngine)
    Q_UNUSED(jsEngine)
    Q_ASSERT(s_instance);
    QJSEngine::setObjectOwnership(s_instance, QJSEngine::CppOwnership);
    return s_instance;
}

int EventStore::count() const
{
    return int(m_events.size());
}

int EventStore::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : count();
}

QVariant EventStore::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid)) {
        return QVariant();
    }
    const Event &event = m_events.at(index.row());
    switch (role) {
    case EventIdRole:
        return event.id;
    case EventNameRole:
        return event.name;
    case EventDateRole:
        return event.date;
    case TextColorRole:
        return event.color;
    case PosXRole:
        return event.x;
    case PosYRole:
        return event.y;
    case LockedRole:
        return event.locked;
    case NotifiedDateRole:
        return event.notifiedDate;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> EventStore::roleNames() const
{
    return {
        {EventIdRole, "eventId"},
        {EventNameRole, "eventName"},
        {EventDateRole, "eventDate"},
        {TextColorRole, "textColor"},
        {PosXRole, "posX"},
        {PosYRole, "posY"},
        {LockedRole, "locked"},
        {NotifiedDateRole, "notifiedDate"},
    };
}

QString EventStore::addEvent()
{
    Event event;
    event.id = QUuid::createUuid().toString(QUuid::WithoutBraces);
    event.date = QDateTime(QDate::currentDate().addDays(7), QTime(0, 0)).toString(QStringLiteral("yyyy-MM-ddTHH:mm"));
    event.color = QStringLiteral("#ffffff");

    beginInsertRows(QModelIndex(), count(), count());
    m_events.append(event);
    endInsertRows();

    save(event);
    saveOrder();
    Q_EMIT countChanged();
    return event.id;
}

void EventStore::removeEvent(const QString &eventId)
{
    const qsizetype row = indexOf(eventId);
    if (row < 0) {
        return;
    }
    beginRemoveRows(QModelIndex(), int(row), int(row));
    m_events.removeAt(row);
    endRemoveRows();

    QSettings().remove(groupFor(eventId));
    saveOrder();
    Q_EMIT countChanged();
}

void EventStore::updateEvent(const QString &eventId, const QVariantMap &values)
{
    const qsizetype row = indexOf(eventId);
    if (row < 0) {
        return;
    }
    Event &event = m_events[row];
    QList<int> roles;
    for (auto it = values.cbegin(); it != values.cend(); ++it) {
        const QString &key = it.key();
        if (key == QLatin1String("eventName")) {
            event.name = it.value().toString();
            roles.append(EventNameRole);
        } else if (key == QLatin1String("eventDate")) {
            event.date = it.value().toString();
            roles.append(EventDateRole);
        } else if (key == QLatin1String("textColor")) {
            event.color = it.value().toString();
            roles.append(TextColorRole);
        } else if (key == QLatin1String("posX")) {
            event.x = it.value().toInt();
            roles.append(PosXRole);
        } else if (key == QLatin1String("posY")) {
            event.y = it.value().toInt();
            roles.append(PosYRole);
        } else if (key == QLatin1String("locked")) {
            event.locked = it.value().toBool();
            roles.append(LockedRole);
        } else if (key == QLatin1String("notifiedDate")) {
            event.notifiedDate = it.value().toString();
            roles.append(NotifiedDateRole);
        } else {
            qWarning() << "EventStore: unknown field" << key;
        }
    }
    if (roles.isEmpty()) {
        return;
    }
    const QModelIndex changed = index(int(row));
    Q_EMIT dataChanged(changed, changed, roles);
    save(event);
}

void EventStore::load()
{
    QSettings settings;
    const QStringList order = settings.value(OrderKey).toStringList();
    for (const QString &eventId : order) {
        settings.beginGroup(groupFor(eventId));
        Event event;
        event.id = eventId;
        event.name = settings.value(QStringLiteral("name")).toString();
        event.date = settings.value(QStringLiteral("date")).toString();
        event.color = settings.value(QStringLiteral("color"), QStringLiteral("#ffffff")).toString();
        event.x = settings.value(QStringLiteral("x"), -1).toInt();
        event.y = settings.value(QStringLiteral("y"), -1).toInt();
        event.locked = settings.value(QStringLiteral("locked"), false).toBool();
        event.notifiedDate = settings.value(QStringLiteral("notifiedDate")).toString();
        settings.endGroup();
        m_events.append(event);
    }
}

void EventStore::save(const Event &event) const
{
    QSettings settings;
    settings.beginGroup(groupFor(event.id));
    settings.setValue(QStringLiteral("name"), event.name);
    settings.setValue(QStringLiteral("date"), event.date);
    settings.setValue(QStringLiteral("color"), event.color);
    settings.setValue(QStringLiteral("x"), event.x);
    settings.setValue(QStringLiteral("y"), event.y);
    settings.setValue(QStringLiteral("locked"), event.locked);
    settings.setValue(QStringLiteral("notifiedDate"), event.notifiedDate);
    settings.endGroup();
}

void EventStore::saveOrder() const
{
    QStringList order;
    order.reserve(m_events.size());
    for (const Event &event : m_events) {
        order.append(event.id);
    }
    QSettings().setValue(OrderKey, order);
}

qsizetype EventStore::indexOf(const QString &eventId) const
{
    for (qsizetype i = 0; i < m_events.size(); ++i) {
        if (m_events.at(i).id == eventId) {
            return i;
        }
    }
    return -1;
}

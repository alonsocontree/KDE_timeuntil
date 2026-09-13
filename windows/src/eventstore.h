// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QQmlEngine>
#include <QString>

// The countdown events, one window each, saved with QSettings (the
// registry on Windows). Dates use the same yyyy-MM-ddTHH:mm local-time
// format as the Plasma widget.
class EventStore : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Role {
        EventIdRole = Qt::UserRole + 1,
        EventNameRole,
        EventDateRole,
        TextColorRole,
        PosXRole,
        PosYRole,
        LockedRole,
        NotifiedDateRole,
    };
    Q_ENUM(Role)

    // Not default-constructible on purpose: otherwise QML would build its
    // own instance instead of calling create().
    explicit EventStore(QObject *parent);
    ~EventStore() override;

    // QML gets the instance created in main().
    static EventStore *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Adds an event a week from today and returns its id.
    Q_INVOKABLE QString addEvent();
    Q_INVOKABLE void removeEvent(const QString &eventId);
    // Changes the given roles, e.g. { eventName: "Vienna", eventDate: "2026-11-05T18:00" }.
    Q_INVOKABLE void updateEvent(const QString &eventId, const QVariantMap &values);

Q_SIGNALS:
    void countChanged();

private:
    struct Event {
        QString id;
        QString name;
        QString date;
        QString color;
        int x = -1;
        int y = -1;
        bool locked = false;
        QString notifiedDate;
    };

    void load();
    void save(const Event &event) const;
    void saveOrder() const;
    qsizetype indexOf(const QString &eventId) const;

    QList<Event> m_events;

    static inline EventStore *s_instance = nullptr;
};

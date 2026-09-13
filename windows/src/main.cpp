// SPDX-License-Identifier: GPL-3.0-or-later

#include <QApplication>
#include <QLocale>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "eventstore.h"
#include "localizedcontext.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QApplication::setOrganizationName(QStringLiteral("TimeUntil"));
    QApplication::setApplicationName(QStringLiteral("TimeUntil"));
    QApplication::setApplicationVersion(QStringLiteral(TIMEUNTIL_VERSION));

#ifdef Q_OS_WIN
    QQuickStyle::setStyle(QStringLiteral("FluentWinUI3"));
#endif

    // LANGUAGE first, like gettext, so translations can be tried out anywhere.
    QStringList languages = qEnvironmentVariable("LANGUAGE").split(QLatin1Char(':'), Qt::SkipEmptyParts);
    languages += QLocale::system().uiLanguages();

    // Created before the engine so it outlives every QML object using it.
    EventStore eventStore(nullptr);

    QQmlApplicationEngine engine;
    auto *localizedContext = new LocalizedContext(&engine);
    localizedContext->loadTranslations(languages);
    engine.rootContext()->setContextObject(localizedContext);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        [] {
            QCoreApplication::exit(1);
        },
        Qt::QueuedConnection);
    engine.loadFromModule("TimeUntil", "Main");

    return app.exec();
}

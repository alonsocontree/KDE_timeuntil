cmake_minimum_required(VERSION 3.21)

project(TimeUntil VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Widgets)
qt_standard_project_setup(REQUIRES 6.8)

# The plasmoid package holds the code shared with the Plasma widget.
set(SHARED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../plasma/contents")
set(PO_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../po")

qt_add_executable(TimeUntil WIN32
    src/main.cpp
    src/eventstore.cpp src/eventstore.h
    src/localizedcontext.cpp src/localizedcontext.h
)

target_compile_definitions(TimeUntil PRIVATE TIMEUNTIL_VERSION="${PROJECT_VERSION}")
# The generated QML type registration includes the headers by file name.
target_include_directories(TimeUntil PRIVATE src)

# Shared files keep the relative paths they have in the plasmoid, so
# CountdownView.qml still finds ../code/countdown.mjs. The app's own QML
# files sit at the module root.
set_source_files_properties("${SHARED_DIR}/ui/CountdownView.qml" PROPERTIES QT_RESOURCE_ALIAS ui/CountdownView.qml)
set_source_files_properties("${SHARED_DIR}/code/countdown.mjs" PROPERTIES QT_RESOURCE_ALIAS code/countdown.mjs)
set(APP_QML_FILES
    qml/Main.qml
    qml/CountdownWindow.qml
)
foreach(file IN LISTS APP_QML_FILES)
    get_filename_component(name "${file}" NAME)
    set_source_files_properties("${file}" PROPERTIES QT_RESOURCE_ALIAS "${name}")
endforeach()

qt_add_qml_module(TimeUntil
    URI TimeUntil
    # Keep the module's qmldir folder away from the TimeUntil executable.
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/qml/TimeUntil"
    QML_FILES
        ${APP_QML_FILES}
        "${SHARED_DIR}/ui/CountdownView.qml"
        "${SHARED_DIR}/code/countdown.mjs"
)

# Translations are read straight from the .po files shared with the plasmoid.
file(GLOB PO_FILES CONFIGURE_DEPENDS "${PO_DIR}/*.po")
qt_add_resources(TimeUntil translations
    PREFIX /i18n
    BASE "${PO_DIR}"
    FILES ${PO_FILES}
)

target_link_libraries(TimeUntil PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::Widgets)

install(TARGETS TimeUntil RUNTIME DESTINATION .)

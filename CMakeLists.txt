cmake_minimum_required(VERSION 3.16)

project(plasma-macos-dock)

set(PROJECT_DEP_VERSION "6.0.0")
set(QT_MIN_VERSION "6.6.0")
set(KF6_MIN_VERSION "6.0.0")

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMQtDeclareLoggingCategory)

find_package(Qt6 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    Core
    Qml
    Quick
)

find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS
    Config
    ConfigWidgets
    I18n
    KIO
    Notifications
    Service
    WindowSystem
)

find_package(Plasma ${PROJECT_DEP_VERSION} REQUIRED)
find_package(PlasmaActivities ${PROJECT_DEP_VERSION} REQUIRED)
find_package(PlasmaActivitiesStats ${PROJECT_DEP_VERSION} REQUIRED)
find_package(KSysGuardCore REQUIRED)
find_package(PlasmaWorkspace ${PROJECT_DEP_VERSION} REQUIRED)

add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_com.github.mattanis.macosdock\")

plasma_add_applet(com.github.mattanis.macosdock
    QML_SOURCES
        contents/ui/AudioStream.qml
        contents/ui/Badge.qml
        contents/ui/ConfigAppearance.qml
        contents/ui/ConfigBehavior.qml
        contents/config/config.qml
        contents/ui/ContextMenu.qml
        contents/ui/GroupDialog.qml
        contents/ui/GroupExpanderOverlay.qml
        contents/ui/main.qml
        contents/ui/MouseHandler.qml
        contents/ui/PipeWireThumbnail.qml
        contents/ui/PlayerController.qml
        contents/ui/PulseAudio.qml
        contents/ui/ScrollableTextWrapper.qml
        contents/ui/TaskBadgeOverlay.qml
        contents/ui/TaskList.qml
        contents/ui/TaskProgressOverlay.qml
        contents/ui/Task.qml
        contents/ui/ToolTipDelegate.qml
        contents/ui/ToolTipInstance.qml
        contents/ui/ToolTipWindowMouseArea.qml
        contents/ui/code/LayoutMetrics.js
        contents/ui/code/TaskTools.js
    CPP_SOURCES
        src/backend.cpp
        src/smartlauncherbackend.cpp
        src/smartlauncheritem.cpp
    RESOURCES
        contents/config/main.xml
    GENERATE_APPLET_CLASS
)

kconfig_add_kcfg_files(com.github.mattanis.macosdock ${CMAKE_CURRENT_SOURCE_DIR}/src/kactivitymanagerd_plugins_settings.kcfgc)

ecm_qt_declare_logging_category(com.github.mattanis.macosdock
    HEADER log_settings.h
    IDENTIFIER TASKMANAGER_DEBUG
    CATEGORY_NAME com.github.mattanis.macosdock)

target_link_libraries(com.github.mattanis.macosdock PRIVATE
                      Qt::Core
                      Qt::Qml
                      Qt::Quick
                      Plasma::Activities
                      Plasma::ActivitiesStats
                      KF6::ConfigGui
                      KF6::I18n
                      KF6::KIOCore
                      KF6::KIOGui
                      KF6::KIOFileWidgets
                      KF6::Notifications
                      Plasma::Plasma
                      KSysGuard::ProcessCore
                      KF6::Service
                      KF6::WindowSystem
                      PW::LibNotificationManager)

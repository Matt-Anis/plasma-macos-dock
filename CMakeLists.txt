cmake_minimum_required(VERSION 3.16)

project(plasma-macos-dock)

set(KF6_MIN_VERSION "6.0.0")

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)

find_package(Plasma ${KF6_MIN_VERSION} REQUIRED)

plasma_install_package(. com.github.mattanis.macosdock)

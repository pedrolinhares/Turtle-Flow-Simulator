QT += core gui widgets

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = tfs
TEMPLATE = app
QMAKE_CXXFLAGS += -std=c++11

DESTDIR = bin
OBJECTS_DIR = src/interface/build
MOC_DIR = src/interface/build

RESOURCES = src/interface/resources.qrc
RCC_DIR = src/interface/build

SOURCES += src/interface/main.cpp \
        src/interface/kernel_configurator.cpp \
        src/interface/fluid_definitions.cpp \
        src/interface/main_window.cpp \
        src/interface/fluid_dialog.cpp \
        src/interface/grid.cpp \
        src/interface/start_dialog.cpp \
        src/interface/CPlot.cpp \
        src/interface/CGnuplot.cpp

HEADERS  += src/interface/kernel_configurator.h \
            src/interface/main_window.h \
            src/interface/fluid_dialog.h \
            src/interface/fluid_definitions.h \
            src/interface/grid.h \
            src/interface/start_dialog.h \
            src/interface/kernel_definitions.h \
            src/interface/CPlot.h \
            src/interface/CGnuplot.h

QT += core gui widgets

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = interface
TEMPLATE = app
QMAKE_CXXFLAGS += -std=c++11

DESTDIR = bin
OBJECTS_DIR = build
MOC_DIR = build

SOURCES += src/main.cpp \
        src/kernel_configurator.cpp \
        src/main_window.cpp \
        src/fluid_dialog.cpp \
        src/grid.cpp \
        src/start_dialog.cpp \
        kernel/CPlot.cpp \
        kernel/CGnuplot.cpp

HEADERS  += src/kernel_configurator.h \
            src/main_window.h \
            src/fluid_dialog.h \
            src/grid.h \
            src/start_dialog.h \
            src/kernel_definitions.h \
            kernel/CPlot.h \
            kernel/CGnuplot.h
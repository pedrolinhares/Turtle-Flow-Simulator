QT += core gui widgets

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = interface
TEMPLATE = app
QMAKE_CXXFLAGS += -std=c++11

DESTDIR = app
OBJECTS_DIR = build
MOC_DIR = build

SOURCES += src/main.cpp \
        src/main_window.cpp \
        src/fluid_dialog.cpp \
        src/grid.cpp \
        src/startDialog.cpp

HEADERS  += src/main_window.h \
            src/fluid_dialog.h \
            src/grid.h \
            src/startDialog.h
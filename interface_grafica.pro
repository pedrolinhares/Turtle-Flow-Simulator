QT += core gui widgets

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = interface
TEMPLATE = app
QMAKE_CXXFLAGS += -std=c++11


SOURCES += main.cpp \
        main_window.cpp \
        fluid_dialog.cpp \
        grid.cpp \
        startDialog.cpp

HEADERS  += main_window.h \
            fluid_dialog.h \
            grid.h \
            startDialog.h
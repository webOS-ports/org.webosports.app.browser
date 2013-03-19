TEMPLATE = app
TARGET = org.webosports.app.browser
CONFIG += qt warn_on link_pkgconfig
QT += core gui declarative network

PKGCONFIG = glib-2.0 gthread-2.0

target.path += $$[QT_INSTALL_BINS]
INSTALLS += target

SOURCES += \
    main.cpp \
    browserapplication.cpp

HEADERS += \
    browserapplication.h

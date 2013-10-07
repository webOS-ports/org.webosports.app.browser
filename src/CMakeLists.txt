include_directories(
    ${Qt5WebKit_PRIVATE_INCLUDE_DIRS}
    ${Qt5Quick_PRIVATE_INCLUDE_DIRS})

set(SOURCES
    BrowserApplication.cpp
    BrowserWindow.cpp
    main.cpp
    UrlLoader.cpp
    utils.cpp)

qt5_add_resources(RESOURCES resources.qrc)

add_executable(universe-browser ${SOURCES} ${RESOURCES})
qt5_use_modules(universe-browser Quick Gui WebKit)
target_link_libraries(universe-browser)

set(APPLICATION_DATA
    icon.png
    icon-256x256.png
    appinfo.json)

install (FILES ${APPLICATION_DATA} DESTINATION ${WEBOS_INSTALL_WEBOS_APPLICATIONSDIR}/org.webosports.app.browser)

webos_build_program()

include_directories(
	${Qt5WebKit_PRIVATE_INCLUDE_DIRS}
	${Qt5Quick_PRIVATE_INCLUDE_DIRS})

set(SOURCES
    plugin.cpp
    browserutils.cpp)

add_library(browserutils MODULE ${SOURCES})
qt5_use_modules(browserutils Quick WebKit)

execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
                                                              "${CMAKE_CURRENT_BINARY_DIR}/qmldir")

install(TARGETS browserutils DESTINATION ${APP_DIR}/browserutils)
install(FILES qmldir DESTINATION ${APP_DIR}/browserutils)

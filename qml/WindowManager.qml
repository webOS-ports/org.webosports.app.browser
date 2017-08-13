/*
* Copyright (C) 2015 Simon Busch <morphis@gravedo.de>
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>
*/

import QtQuick 2.0

Item {
    id: windowManager

    ListModel {
        id: windowModel
    }

    function handleWindowClose(window) {
        window.destroy();

        for (var n = 0; n < windowModel.count; n++) {
            var win = windowModel.get(n).window;
            if (win === window) {
                windowModel.remove(n);
                break;
            }
        }
    }

    function findActiveWindow() {
        for (var n = 0; n < windowModel.count; n++) {
            var window = windowModel.get(n).window;
            if (window.active)
                return window;
        }
        return null;
    }

    function openNewCardForRequest(request) {
        var newWindow = create("");
        request.openIn(newWindow.internalWebView);
    }

    function create(url) {
        var parentWindow = findActiveWindow();
        var parentWindowId = (parentWindow !== null)?parentWindow.windowId:0;
        var windowComponent = Qt.createComponent(Qt.resolvedUrl("BrowserWindow.qml"));
        if(windowComponent.status===Component.Ready) {
            var window = windowComponent.createObject(windowManager, {
                                                          url: url,
                                                          windowManager: windowManager,
                                                          parentWindowId: parentWindowId
                                                      });
            windowModel.append({window: window });
            window.closed.connect(handleWindowClose);
            window.openNewCardForRequest.connect(openNewCardForRequest);

            return window;
        }
        else {
            console.error("Error during instantiation of BrowserWindow.qml!");
            console.error(windowComponent.errorString());
        }
    }
}

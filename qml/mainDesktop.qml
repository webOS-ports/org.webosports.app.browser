/*
* Copyright (C) 2014 Herman van Hazendonk <github.com@herrie.org>
* Copyright (C) 2014 Christophe Chapuis <chris.chapuis@gmail.com>
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

import LuneOS.Service 1.0

Item {
    id: desktopRoot

    width: 1024
    height: 768

    property QtObject application: QtObject {
        property string launchParameters: "{}"
        signal relaunched(string parameters);
    }

    LunaService {
        id: luna
        name: "org.webosports.app.browser"
    }
    Db8Model {
        kind: "com.palm.browserbookmarks:1"
        query: ({})
        Component.onCompleted: {
            // Fill in the stub db8 for history and bookmarks
            luna.call("luna://com.palm.db/find", '{"query":{"from":"com.palm.browserbookmarks:1", "limit":32}}',
                      function (message) {
                          var payload = JSON.parse(message.payload);
                          put(payload.results);
                      }, undefined);
        }
    }
    Db8Model {
        kind: "com.palm.browserhistory:1"
        query: ({})
        Component.onCompleted: {
            // Fill in the stub db8 for history and bookmarks
            luna.call("luna://com.palm.db/find", '{"query":{"from":"com.palm.browserhistory:1", "limit":50, "orderBy":"date"}}',
                      function (message) {
                          var payload = JSON.parse(message.payload);
                          put(payload.results);
                      }, undefined);
        }
    }

    Component.onCompleted: {
        var mainComponent = Qt.createComponent("main.qml");
        if(mainComponent.status===Component.Ready) {
            var mainObject = mainComponent.createObject(desktopRoot);
        }
        else {
            console.error("Error during instantiation of main.qml!");
            console.error(mainComponent.errorString());
        }
    }
}


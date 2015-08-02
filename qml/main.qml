/*
* Copyright (C) 2014 Simon Busch <morphis@gravedo.de>
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
import QtQuick.Window 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import LunaNext.Common 0.1
import "Utils"
import "js/util.js" as EnyoUtils


Item {
    id: rootItem

    WindowManager {
        id: windowManager
    }

    Component.onCompleted: {
        var lparams = JSON.parse(application.launchParameters);
        windowManager.create(parseInputUrl(lparams.target));
    }

    function parseInputUrl(url) {
        var parsedUrl = "";
        if (url && url.length > 0)
        {
            if (url.substring(0,7)==="http://" || url.substring(0,8)==="https://" ||
                url.substring(0,6)==="ftp://" || url.substring(0,7)==="data://" ||
                url.substring(0,6)==="about:" || url.substring(0,7)==="file://")
            {
                parsedUrl = url;
            }
            else
            {
                //We require http(s) for the URLs to load, so add http for now when it's not available
                parsedUrl = "http://" + url;
            }
        }
        return parsedUrl;
    }

    Connections {
        target: application
        onRelaunched: {
            console.log("The browser has been relaunched with parameters: " + parameters);
            var params = parameters?JSON.parse(parameters):"";

            if (params && params['palm-command'] === 'open-app-menu') {
                var window = windowManager.findActiveWindow();
                console.log("Current active window " + window);
                if (window !== null)
                    window.activateAppMenu();

                return;
            }

            var targetUrl = "";

            if (params && typeof params.target !== 'undefined')
                targetUrl = params.target;
            targetUrl = parseInputUrl(targetUrl);

            console.log("Creating new window with target " + targetUrl);
            windowManager.create(targetUrl);
        }
    }
}

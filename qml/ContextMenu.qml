/*
* Copyright (C) 2014 Simon Busch <morphis@gravedo.de>
* Copyright (C) 2014 Herman van Hazendonk <github.com@herrie.org>
* Copyright (C) 2014 Christophe Chapuis <chris.chapuis@gmail.com>
* Copyright (C) 2015 Nikolay Nizov <nizovn@gmail.com>
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

import QtQuick 2.1
import QtWebEngine.UIDelegates 1.0

Item {
    property QtObject ctxMenuInfo

    MenuItem {
        text: "Open in New Card"
        onTriggered: openNewCard(ctxMenuInfo.linkUrl);
    }
    MenuItem {
        text: "Share Link"
        onTriggered: shareLinkViaEmail(ctxMenuInfo.linkUrl, ctxMenuInfo.linkText);
    }

    signal openNewCard(string url)
    signal shareLinkViaEmail(string url, string text)
    signal copyURL(string url)
}


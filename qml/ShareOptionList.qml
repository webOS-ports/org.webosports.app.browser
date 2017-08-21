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
import QtQuick 2.6

import QtQuick.Controls 2.0
import QtQuick.Controls.LuneOS 2.0

import LunaNext.Common 0.1
import "js/util-sharing.js" as SharingUtils

Menu {
    id: optionsMenu
    width: Units.gu(23) //When we have Messaging we need to make it wider //Units.gu(30)
    transformOrigin: Menu.TopRight

    signal showBookmarkDialog(string action, string buttonText)

    MenuItem {
        height:Units.gu(5)
        text: "Add Bookmark"
        onTriggered: showBookmarkDialog("addBookmark", "Add Bookmark");
    }
    MenuItem {
        height:Units.gu(5)
        text: "Share Link via Email"
        onTriggered: SharingUtils.shareLinkViaEmail(webViewItem.url, webViewItem.title);
    }
    /*
    MenuItem {
        height:Units.gu(5)
        text: "Share Link via Messaging"
        onTriggered: SharingUtils.shareLinkViaMessaging(webViewItem.url, webViewItem.title);
    }
    */
    MenuItem {
        height:Units.gu(5)
        text: "Add to Launcher"
        onTriggered: showBookmarkDialog("addToLauncher", "Add to Launcher");
    }
}

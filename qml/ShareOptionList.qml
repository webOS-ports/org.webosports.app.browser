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
import LunaNext.Common 0.1
import "js/util-sharing.js" as SharingUtils

ListView {
    id: shareOptionsListView
    width: Units.gu(18) //When we have Messaging we need to make it wider //Units.gu(23)
    height: shareOptionsModel.count * optionsRectHeight
    visible: false
    z: 5

    property real optionsRectHeight: Units.gu(5)

    signal showBookmarkDialog(string action, string buttonText)

    function show() {
        visible = true;
    }
    function hide() {
        visible = false;
    }

    Rectangle {
        height: parent.height
        width: parent.width
        radius: 6
        border.width: Units.gu(1 / 10)
        border.color: "#7D7D7D"
        color: "transparent"
        z: 5
    }

    ListModel {
        id: shareOptionsModel
        ListElement {
            action: "Add Bookmark"
            actionName: "addBookmark"
        }
        ListElement {
            action: "Share Link via Email"
            actionName: "shareLinkEmail"
        }
        /*ListElement {
                    action: "Share Link via Messaging"
                                actionName: "shareLinkMessaging"
                                        }*/
        ListElement {
            action: "Add to Launcher"
            actionName: "addToLauncher"
        }
    }

    model: shareOptionsModel

    delegate: Rectangle {
        id: optionRect
        height: optionsRectHeight
        width: parent.width
        anchors.left: parent.left
        color: "#D9D9D9"
        z: 5

        Text {
            id: optionName
            height: optionRect.height
            clip: true
            width: parent.width
            anchors.left: optionRect.left
            anchors.leftMargin: Units.gu(1)
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.family: "Prelude"
            font.pixelSize: FontUtils.sizeToPixels("medium")
            color: "#494949"
            text: action
            z: 5
        }
        Rectangle {
            color: "silver"
            height: Units.gu(1 / 10)
            width: parent.width
            anchors.top: parent.top
            z: 5
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (actionName === "shareLinkEmail") {
                    SharingUtils.shareLinkViaEmail(webViewItem.url,
                                                webViewItem.title)
                } else if (actionName === "shareLinkMessaging") {
                    SharingUtils.shareLinkViaMessaging(webViewItem.url,
                                                    webViewItem.title)
                } else if (actionName === "addToLauncher") {
                    showBookmarkDialog("addToLauncher", "Add to Launcher");
                } else if (actionName === "addBookmark") {
                    showBookmarkDialog("addBookmark", "Add Bookmark");
                }
            }
        }
    }
}

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
import "js/util.js" as EnyoUtils

ListView {
    anchors.top: progressBar.bottom
    anchors.right: progressBar.right
    anchors.rightMargin: Units.gu(2)
    width: Units.gu(
               18) //When we have Messaging we need to make it wider //Units.gu(23)
    height: Units.gu(30)
    visible: false
    z: 5

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
        height: Units.gu(5)
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
                    EnyoUtils.shareLinkViaEmail(webViewItem.url,
                                                webViewItem.title)
                } else if (actionName === "shareLinkMessaging") {
                    EnyoUtils.shareLinkViaMessaging(webViewItem.url,
                                                    webViewItem.title)
                } else if (actionName === "addToLauncher") {
                    dimBackground.visible = true
                    bookmarkDialog.action = "addToLauncher"
                    bookmarkDialog.myURL = "" + webViewItem.url
                    bookmarkDialog.myTitle = webViewItem.title
                    bookmarkDialog.myButtonText = "Add to Launcher"
                    bookmarkDialog.visible = true
                } else if (actionName === "addBookmark") {
                    dimBackground.visible = true
                    bookmarkDialog.action = "addBookmark"
                    bookmarkDialog.myURL = "" + webViewItem.url
                    bookmarkDialog.myTitle = webViewItem.title
                    bookmarkDialog.myButtonText = "Add Bookmark"
                    bookmarkDialog.visible = true
                }

                shareOptionsList.visible = false
            }
        }

        Component.onCompleted: {
            shareOptionsList.height = (shareOptionsModel.count) * optionRect.height
        }
    }
}

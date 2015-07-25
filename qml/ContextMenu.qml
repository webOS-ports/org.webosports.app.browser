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

import QtQuick 2.0
import LunaNext.Common 0.1
import "js/util.js" as EnyoUtils

Item {
    id: contextMenuRoot
    anchors.fill: parent
    visible: false

    function hide() {
        contextMenuRoot.visible = false
        contextMenu.contextURL = ""
        contextMenu.contextText = ""
        contextMenuList.currentIndex = -1
    }

    function show(data) {
        var x = data.pageX
        var y = data.pageY
        contextMenu.contextURL = data.href
        contextMenu.contextText = data.text
        y = y-contextMenu.sectionHeight
        if (x+contextMenu.width>contextMenuRoot.width)
            x = x-contextMenu.width
        if (y+contextMenu.height>contextMenuRoot.height)
            y = y-contextMenu.width
        contextMenu.x = x
        contextMenu.y = y
        contextMenuRoot.visible = true
    }

    MouseArea {
        id: outsideSensingArea
        anchors.fill: parent
        onClicked: { contextMenuRoot.hide() }
    }

    signal openNewCard(string url)
    signal shareLink(string url)
    signal copyURL(string url)

    onOpenNewCard: {
        window.openNewCard(url)
    }

    onShareLink: {
        EnyoUtils.shareLinkViaEmail(url, contextMenu.contextText)
    }

    onCopyURL: {
        window.setClipboard(url)
    }

    ListModel {
        id: linkItems
        ListElement { caption: "Open in New Card"; value: "openNewCard" }
        ListElement { caption: "Share Link"; value: "shareLink" }
        ListElement { caption: "Copy URL"; value: "copyURL" }
    }

    Rectangle {
        id: contextMenu
        property string contextURL: ""
        property string contextText: ""
        property real sectionHeight: Units.gu(5)

        width: Units.gu(18)
        height: contextMenuList.model.count*sectionHeight+2*border.width
        radius: Units.gu(0.6)
        border.width: Units.gu(0.1)
        border.color: "#7D7D7D"
        color: "#D9D9D9"

        ListView {
            id: contextMenuList
            anchors.fill: parent
            anchors.margins: contextMenu.border.width
            interactive: false

            highlight: Rectangle {
                color: "powderblue"
                height: contextMenu.sectionHeight
                radius: Units.gu(0.6)

                property bool isValidItem: contextMenuList.currentItem !== null
                width: (isValidItem)?parent.width:0
                y: (isValidItem)?contextMenuList.currentItem.y:0
                x: (isValidItem)?contextMenuList.currentItem.x:0

                Rectangle {
                    color: parent.color
                    visible: contextMenuList.currentIndex < contextMenuList.count-1
                    x: 0
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 2*parent.radius
                }

                Rectangle {
                    color: parent.color
                    visible: contextMenuList.currentIndex > 0
                    x: 0
                    y: 0
                    width: parent.width
                    height: 2*parent.radius
                }
            }

            highlightFollowsCurrentItem: false
            currentIndex: -1

            model: linkItems

            delegate: Item {
                id: sectionRect
                height: contextMenu.sectionHeight
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    height: parent.height
                    clip: true
                    width: parent.width
                    anchors.left: parent.left
                    anchors.leftMargin: Units.gu(1.5)
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Prelude"
                    font.pixelSize: FontUtils.sizeToPixels("medium")
                    color: "#494949"
                    text: caption
                }

                Rectangle {
                    color: "silver"
                    height: Units.gu(0.1)
                    width: parent.width
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: index>0
                }

                MouseArea {
                    anchors.fill: parent

                    onEntered: {
                        contextMenuList.currentIndex = index
                    }

                    onExited: {
                        contextMenuList.currentIndex = -1
                    }

                    onClicked: {
                        contextMenuRoot[value](contextMenu.contextURL)
                        contextMenuRoot.hide()
                    }
                }
            }
        }
    }
}

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

import "Models"

//For sure not the cleanest or nicest implementation, but QML is a bit limited with it's
//dialogs in QT 5.2 so doing it the nasty way for now to resemble legacy look
Popup {
    id: bookmarkDialog

    property string action: ""
    property string myURL: ""
    property string myTitle: ""
    property string myBookMarkIcon: ""
    property string myBookMarkId: ""
    property string myButtonText: ""

    property BookmarkDbModel bookmarksDbModel

    topPadding: Units.gu(3)
    leftPadding: Units.gu(4)
    rightPadding: Units.gu(4)
    modal: true

    Column {
        id: dialogContentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        spacing: Units.gu(1)

        Image {
            id: bookMarkFrame
            source: "images/bookmark-icon-frame.png"
            anchors.horizontalCenter: parent.horizontalCenter
            height: Units.gu(5.2*4/3.)
            width: Units.gu(5.2*4/3.)
            Image {
                id: bookMarkImage
                source: bookmarkDialog.myBookMarkIcon ? bookmarkDialog.myBookMarkIcon : "images/bookmark-icon-default.png"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset : -Units.gu(0.1)
                height: Units.gu(6.4)
                width: Units.gu(6.4)
            }
        }

        Item {
            width: parent.width
            height: Units.gu(6)

            anchors.topMargin: Units.gu(1.5)

            BorderImage {
                id: titleBG

                anchors.fill: parent

                source: "images/input-default-focus.png"
                border.left: 25; border.right: 25
                visible: false
            }

            TextInput {
                id: title
                width: parent.width - Units.gu(2)
                height: Units.gu(3)
                anchors.centerIn: parent

                selectedTextColor: "#000000"
                selectionColor: "#FDFD65"
                text: bookmarkDialog.myTitle ? bookmarkDialog.myTitle : bookmarkDialog.myURL
                clip: true
                horizontalAlignment: TextInput.AlignLeft
                focus: true
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("large")
                color: "black"
                cursorPosition: 1
                onActiveFocusChanged: {
                    if (title.activeFocus) {
                        title.selectAll()
                        titleBG.visible = true
                    } else {
                        titleBG.visible = false
                    }
                }
            }
        }

        Item {
            width: parent.width
            height: Units.gu(6)

            anchors.topMargin: Units.gu(1.5)

            BorderImage {
                id: urlBG

                anchors.fill: parent

                source: "images/input-default-focus.png"
                border.left: 25; border.right: 25
                visible: false
            }

            TextInput {
                id: url
                width: parent.width - Units.gu(2)
                height: Units.gu(3)
                anchors.centerIn: parent

                clip: true
                focus: true
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("large")
                color: "black"
                selectedTextColor: "#000000"
                selectionColor: "#FDFD65"
                text: bookmarkDialog.myURL
                inputMethodHints: Qt.ImhUrlCharactersOnly

                onActiveFocusChanged: {
                    if (url.activeFocus) {
                        urlBG.visible = true
                        url.selectAll()
                    } else {
                        urlBG.visible = false
                    }
                }
            }
        }

        //Confirm/Save Button
        Rectangle {
            width: parent.width;
            height: Units.gu(4.5)

            radius: 4
            color: "#4B4B4B"

            BorderImage {
                anchors.fill: parent
                source: confirmMouseArea.pressed ? "images/button-down.png" : "images/button-up.png"
                border.left: 19; border.right: 19
            }

            Text {
                font.family: "Prelude"
                text: bookmarkDialog.myButtonText //"Save"
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: FontUtils.sizeToPixels("medium")
            }
            MouseArea {
                id: confirmMouseArea
                anchors.fill: parent
                onClicked: {
                    if (bookmarkDialog.action === "editBookmark") {
                        bookmarksDbModel.editBookmark(title.text, url.text,
                                               bookmarkDialog.myBookMarkIcon,
                                               bookmarkDialog.myBookMarkId)
                    } else if (bookmarkDialog.action === "addBookmark") {
                        bookmarksDbModel.addBookmark(title.text, url.text,
                                              bookmarkDialog.myBookMarkIcon)
                    } else if (bookmarkDialog.action === "addToLauncher") {
                        bookmarkDialog.addToLauncher(title.text, url.text,
                                                bookmarkDialog.myBookMarkIcon)
                    }

                    bookmarkDialog.visible = false

                    Qt.inputMethod.hide()
                }
            }
        }

        //Cancel button
        BorderImage {
            width: parent.width;
            height: Units.gu(4.5)
            source: cancelMouseArea.pressed ? "images/button-down.png" : "images/button-up.png"
            border.left: 19; border.right: 19

            Text {
                font.family: "Prelude"
                text: "Cancel"
                anchors.centerIn: parent
                font.pixelSize: FontUtils.sizeToPixels("medium")
            }
            MouseArea {
                id: cancelMouseArea
                anchors.fill: parent
                onClicked: {
                    bookmarkDialog.visible = false
                }
            }
        }
    }

    function addToLauncher(inTitle, inUrl, inIcons) {
        var appParams = {
                    "url": inUrl
                };

        var callParams = {
            "id": "org.webosports.app.browser",
            "icon": inIcons,
            "title": inTitle,
            "params": appParams
        };

        console.log("callparams: "+callParams)
        console.log("JSON.stringify(callParams): "+JSON.stringify({parameters: callParams}))

        luna.call("luna://com.palm.applicationManager/addLaunchPoint", JSON.stringify(callParams),
                  __handleAddLaunchPointSuccess, __handleAddLaunchPointError);
    }

    function __handleAddLaunchPointSuccess(message) {
        console.log("Successfully added App Launchpoint : " + message.payload);
    }

    function __handleAddLaunchPointError(message) {
        console.log("Could not start application : " + message.payload);
    }
}

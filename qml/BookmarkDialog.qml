
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


//For sure not the cleanest or nicest implementation, but QML is a bit limited with it's
//dialogs in QT 5.2 so doing it the nasty way for now to resemble legacy look
Rectangle {
    property string action: ""
    property string myURL: ""
    property string myTitle: ""
    property string myBookMarkIcon: ""
    property string myBookMarkId: ""
    property string myButtonText: ""

    visible: false
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset : -window.keyboardHeight/2.
    width: Units.gu(40)
    height: Units.gu(36)
    color: "transparent"
    radius: 10
    z: 5

    Image {
        id: leftImageTop
        anchors.top: parent.top
        anchors.left: parent.left
        source: "images/dialog-left-top.png"
        height: Units.gu(2.5)
        width: Units.gu(2.5)
    }
    Image {
        id: leftImageMiddle
        height: parent.height - leftImageTop.height - leftImageBottom.height
        anchors.top: leftImageTop.bottom
        anchors.left: parent.left
        source: "images/dialog-left-middle.png"
        fillMode: Image.Stretch
        width: Units.gu(2.5)
    }
    Image {
        id: leftImageBottom
        height: Units.gu(2.5)
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        source: "images/dialog-left-bottom.png"

        width: Units.gu(2.5)
    }

    Image {
        id: centerImageTop
        height: Units.gu(2.5)
        anchors.left: leftImageTop.right
        anchors.top: parent.top
        source: "images/dialog-center-top.png"
        width: parent.width - leftImageTop.width - rightImageTop.width
    }
    Image {
        id: centerImageMiddle
        height: parent.height - centerImageTop.height - centerImageBottom.height
        anchors.left: leftImageMiddle.right
        anchors.top: centerImageTop.bottom
        source: "images/dialog-center-middle.png"
        width: parent.width - leftImageTop.width - rightImageTop.width
        fillMode: Image.Stretch
    }
    Image {
        id: centerImageBottom
        height: Units.gu(2.5)
        anchors.left: leftImageBottom.right
        anchors.bottom: parent.bottom
        source: "images/dialog-center-bottom.png"
        width: parent.width - leftImageBottom.width - rightImageBottom.width
    }

    Image {
        id: rightImageTop
        anchors.right: parent.right
        anchors.top: parent.top
        source: "images/dialog-right-top.png"
        width: Units.gu(2.5)
        height: Units.gu(2.5)
    }
    Image {
        id: rightImageMiddle
        anchors.right: parent.right
        anchors.top: rightImageTop.bottom
        source: "images/dialog-right-middle.png"
        width: Units.gu(2.5)
        height: parent.height - rightImageTop.height - rightImageBottom.height
        fillMode: Image.Stretch
    }

    Image {
        id: rightImageBottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        source: "images/dialog-right-bottom.png"
        width: Units.gu(2.5)
        height: Units.gu(2.5)
    }
    Image {
        id: bookMarkFrame
        source: "images/bookmark-icon-frame.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Units.gu(3)
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

    Rectangle {
        id: titleBG
        width: parent.width - Units.gu(6)
        height: Units.gu(6)
        color: "white"
        radius: 4
        visible: false
        anchors.top: bookMarkFrame.bottom
        anchors.topMargin: Units.gu(1)
        anchors.left: parent.left
        anchors.leftMargin: Units.gu(3)
        Image {
            id: titleBGImageLeft
            source: "images/input-default-focus-left.png"
            anchors.left: titleBG.left
            width: Units.gu(1.2)
            height: parent.height
        }
        Image {
            id: titleBGImageCenter
            source: "images/input-default-focus-center.png"
            anchors.left: titleBGImageLeft.right
            width: parent.width - Units.gu(2.4)
            height: parent.height
        }
        Image {
            id: titleBGImageRight
            source: "images/input-default-focus-right.png"
            anchors.right: parent.right
            width: Units.gu(1.2)
            height: parent.height
        }
    }

    Rectangle {
        id: titleRectangle
        width: parent.width
        height: Units.gu(3)
        anchors.left: parent.left
        anchors.leftMargin: Units.gu(4)
        anchors.top: bookMarkFrame.bottom
        anchors.topMargin: Units.gu(2.5)
        color: "transparent"

        TextInput {
            id: title
            width: parent.width - Units.gu(8)
            anchors.left: titleRectangle.left
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

    Rectangle {
        id: urlBG
        width: parent.width - Units.gu(6)
        height: Units.gu(6)
        color: "white"
        radius: 4
        visible: false
        anchors.top: titleRectangle.bottom
        anchors.topMargin: Units.gu(1.5)
        anchors.left: parent.left
        anchors.leftMargin: Units.gu(3)
        Image {
            id: urlBGImageLeft
            source: "images/input-default-focus-left.png"
            anchors.left: parent.left
            width: Units.gu(1.2)
            height: parent.height
        }
        Image {
            id: urlBGImageCenter
            source: "images/input-default-focus-center.png"
            anchors.left: urlBGImageLeft.right
            width: parent.width - urlBGImageLeft.width - urlBGImageRight.width
            height: parent.height
        }
        Image {
            id: urlBGImageRight
            source: "images/input-default-focus-right.png"
            anchors.right: parent.right
            width: Units.gu(1.2)
            height: parent.height
        }
    }

    Rectangle {
        id: urlRectangle
        width: parent.width
        height: Units.gu(3)
        anchors.top: titleRectangle.bottom
        anchors.topMargin: Units.gu(3)
        anchors.left: parent.left
        anchors.leftMargin: Units.gu(4)
        color: "transparent"

        TextInput {
            id: url
            width: parent.width - Units.gu(8)
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
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
        id: confirmRect
        height: Units.gu(4.5)
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - Units.gu(6)
        anchors.top: urlBG.bottom
        anchors.topMargin: Units.gu(1)
        radius: 4
        color: "#4B4B4B"
        Image {
            id: confirmImageLeft
            source: "images/button-up-left.png"
            width: Units.gu(1.9)
            height: parent.height
            fillMode: Image.Stretch
            anchors.left: parent.left
        }
        Image {
            id: confirmImageCenter
            source: "images/button-up-center.png"
            width: confirmRect.width - confirmImageLeft.width - confirmImageRight.width
            height: parent.height
            fillMode: Image.Stretch
            anchors.left: confirmImageLeft.right
        }

        Image {
            id: confirmImageRight
            source: "images/button-up-right.png"
            height: parent.height
            fillMode: Image.Stretch
            anchors.right: confirmRect.right
        }

        Text {
            font.family: "Prelude"
            text: bookmarkDialog.myButtonText //"Save"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            font.pixelSize: FontUtils.sizeToPixels("medium")
        }
        MouseArea {
            anchors.fill: parent
            onPressed: {
                if (bookmarkDialog.action === "editBookmark") {
                    EnyoUtils.editBookmark(title.text, url.text,
                                           bookmarkDialog.myBookMarkIcon,
                                           bookmarkDialog.myBookMarkId)
                } else if (bookmarkDialog.action === "addBookmark") {
                    EnyoUtils.addBookmark(title.text, url.text,
                                          bookmarkDialog.myBookMarkIcon)
                } else if (bookmarkDialog.action === "addToLauncher") {
                    EnyoUtils.addToLauncher(title.text, url.text,
                                            bookmarkDialog.myBookMarkIcon)
                }

                bookmarkDialog.visible = false
                dimBackground.visible = false
                window.__queryDB(
                            "find",
                            '{"query":{"from":"com.palm.browserbookmarks:1", "limit":32}}')
                Qt.inputMethod.hide()
            }
        }
    }

    //Cancel button
    Rectangle {
        id: cancelRect
        height: Units.gu(4.5)
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - Units.gu(6)
        anchors.top: confirmRect.bottom
        anchors.topMargin: Units.gu(1)
        color: "transparent"
        radius: 4
        Image {
            id: cancelImageLeft
            source: "images/button-up-left.png"
            width: Units.gu(1.9)
            height: parent.height
            fillMode: Image.Stretch
            anchors.left: parent.left
        }
        Image {
            id: cancelImageCenter
            source: "images/button-up-center.png"
            width: cancelRect.width - cancelImageLeft.width - cancelImageRight.width
            height: parent.height
            fillMode: Image.Stretch
            anchors.left: cancelImageLeft.right
        }

        Image {
            id: cancelImageRight
            source: "images/button-up-right.png"
            height: parent.height
            fillMode: Image.Stretch
            anchors.right: cancelRect.right
        }

        Text {
            font.family: "Prelude"
            text: "Cancel"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: FontUtils.sizeToPixels("medium")
        }
        MouseArea {
            anchors.fill: parent
            onPressed: {
                bookmarkDialog.visible = false
                dimBackground.visible = false
            }
        }
    }
}

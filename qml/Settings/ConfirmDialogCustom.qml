
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


//For sure not the cleanest or nicest implementation, but QML is a bit limited with it's
//dialogs in QT 5.2 so doing it the nasty way for now to resemble legacy look
Item {
    id: confirmDialogRoot

    property alias buttonText: clearText.text
    property alias title: titleTextItem.text
    visible: false
    width: Units.gu(40)
    height: Units.gu(23)

    signal commitAction();

    function show() {
        confirmDialogRoot.visible = true;
    }
    function hide() {
        confirmDialogRoot.visible = false;
    }

    BorderImage {
        source: "../images/dialog-bg.png"
        anchors.fill: parent
        border.left: 25; border.top: 25
        border.right: 25; border.bottom: 25
    }

    Text {
        id: clearText
        font.family: "Prelude"
        color: "#292929"
        anchors.left: parent.left
        anchors.leftMargin: Units.gu(2)
        font.pixelSize: FontUtils.sizeToPixels("large")
        anchors.top: parent.top
        anchors.topMargin: Units.gu(3)
        width: parent.width - Units.gu(4)
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }
    Rectangle {
        id: confirmRect
        height: Units.gu(4.5)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.left: clearText.left
        width: parent.width - Units.gu(10)
        anchors.top: clearText.bottom
        anchors.topMargin: Units.gu(1)
        radius: 4
        color: "#c01b1e"
        Image {
            id: confirmImageLeft
            source: "../images/button-up-left.png"
            width: Units.gu(1.9)
            height: parent.height
            fillMode: Image.Stretch
            anchors.left: parent.left
        }
        Image {
            id: confirmImageCenter
            source: "../images/button-up-center.png"
            width: confirmRect.width - confirmImageLeft.width - confirmImageRight.width
            height: parent.height
            fillMode: Image.Stretch
            anchors.left: confirmImageLeft.right
        }

        Image {
            id: confirmImageRight
            source: "../images/button-up-right.png"
            height: parent.height
            fillMode: Image.Stretch
            anchors.right: confirmRect.right
        }

        Text {
            id: titleTextItem
            font.family: "Prelude"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            font.pixelSize: FontUtils.sizeToPixels("medium")
        }
        MouseArea {
            anchors.fill: parent
            onPressed: {
                confirmDialogRoot.commitAction();
                confirmDialogRoot.hide();
            }
        }
    }

    Rectangle {
        id: cancelRect
        height: Units.gu(4.5)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.left: clearText.left
        width: parent.width - Units.gu(10)
        anchors.top: confirmRect.bottom
        anchors.topMargin: Units.gu(1)
        color: "transparent"
        radius: 4
        Image {
            id: cancelImageLeft
            source: "../images/button-up-left.png"
            width: Units.gu(1.9)
            height: parent.height
            fillMode: Image.Stretch
            anchors.left: parent.left
        }
        Image {
            id: cancelImageCenter
            source: "../images/button-up-center.png"
            width: cancelRect.width - cancelImageLeft.width - cancelImageRight.width
            height: parent.height
            fillMode: Image.Stretch
            anchors.left: cancelImageLeft.right
        }

        Image {
            id: cancelImageRight
            source: "../images/button-up-right.png"
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
                confirmDialogRoot.hide();
            }
        }
    }
}


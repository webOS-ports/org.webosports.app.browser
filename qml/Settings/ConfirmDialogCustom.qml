
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

Popup {
    id: confirmDialogRoot

    property alias title: clearText.text
    property alias buttonText: confirmButton.text

    visible: false    
    modal: true

    signal commitAction();

    Column {
        width: parent.width
        spacing: Units.gu(1)

        Text {
            id: clearText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Units.gu(2)
            anchors.rightMargin: Units.gu(2)

            font.family: "Prelude"
            color: "#292929"
            font.pixelSize: FontUtils.sizeToPixels("large")
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
        Button {
            id: confirmButton
            height: Units.gu(4.5)
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Units.gu(2)
            anchors.rightMargin: Units.gu(2)

            LuneOSButton.mainColor: LuneOSButton.negativeColor

            onClicked: {
                confirmDialogRoot.commitAction();
                confirmDialogRoot.close();
            }
        }
        Button {
            id: cancelutton
            height: Units.gu(4.5)
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Units.gu(2)
            anchors.rightMargin: Units.gu(2)

            text: "Cancel"
            LuneOSButton.mainColor: LuneOSButton.secondaryColor

            onClicked: confirmDialogRoot.close();
        }
    }
}


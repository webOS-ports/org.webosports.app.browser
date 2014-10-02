/*
* Copyright (C) 2014 Christophe Chapuis <chris.chapuis@gmail.com>
* Copyright (C) 2014 Herman van Hazendonk <github.com@herrie.org>
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

Item {
    id: menuRoot
    width: Units.gu(23)
    height: Units.gu(4) * menuListView.count

    signal settingsMenuItem
    onSettingsMenuItem: {
        menuRoot.visible = false
        Qt.inputMethod.hide()
    }

    ListView {
        id: menuListView
        anchors.fill: parent

        model: ListModel {
            ListElement {
                itemText: "Preferences..."
                itemAction: "settingsMenuItem"
            }
        }
        delegate: Rectangle {
            color: "#313131"
            width: menuRoot.width
            height: Units.gu(4)
            radius: 4

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                text: itemText
                anchors.leftMargin: Units.gu(1)
                font.family: "Prelude"
                color: "#E5E5E5"
                font.pixelSize: FontUtils.sizeToPixels("medium")
            }
            MouseArea {
                anchors.fill: parent
                onClicked:
                {
                    menuRoot[itemAction]()
                }
            }
        }
    }
}

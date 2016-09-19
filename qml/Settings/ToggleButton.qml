/*
 * Copyright (C) 2015-2016 Herman van Hazendonk <github.com@herrie.org>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; see the file COPYING.  If not, see
 * <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import LunaNext.Common 0.1

Switch {
    style: SwitchStyle {
        groove: Image {
            id: grooveImage
            source: control.checked ? "../images/toggle-button-on.png" : "../images/toggle-button-off.png"
            width: Units.gu(8)
            height: Units.gu(4)

            Text {
                color: "white"
                text: "ON"
                font.bold: true
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("small")
                visible: control.checked
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Units.gu(1.25)
            }
            Text {
                color: "white"
                text: "OFF"
                font.bold: true
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("small")
                visible: !control.checked
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Units.gu(1)
            }

        }
        handle: Rectangle {
            color: "transparent"
        }
    }
}

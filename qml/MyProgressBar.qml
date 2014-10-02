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
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 1.1

	ProgressBar {
        //id: progressBar
        property int minimum: 0
        property int maximum: 100
        property int value: 0
        property string progressBarColor: "#2E8CF7"

        z: 1
        minimumValue: 0
        maximumValue: 100
        height: pageIsLoading ? Units.gu(1/2) : 0
        visible: true
        anchors.top: navigationBar.bottom
        style: ProgressBarStyle {
            background: Rectangle {
                radius: 2
                color: "darkgray"
                border.color: "gray"
                border.width: 1
                implicitWidth: navigationBar.width
                implicitHeight: Units.gu(1 / 2)
            }
            progress: Rectangle {
                id: progressRect
                color: progressBarColor
                border.color: progressBarColor
            }
        }
    }

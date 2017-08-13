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

ProgressBar {
    id: control
    padding: 0

    readonly property string progressBarColor: value === to ? "green" : "#2E8CF7"

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: Units.gu(0.3)
        color: "#e6e6e6"
        radius: 2
    }

    contentItem: Item {
        implicitWidth: 200
        implicitHeight: Units.gu(0.3)

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: progressBarColor
        }
    }
}


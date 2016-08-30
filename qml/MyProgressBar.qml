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
    id: progressBarRoot

    value: 0
    property string progressBarColor: value === 1.0 ? "green" : "#2E8CF7"

    height: Units.gu(0.5)

    style: ProgressBarStyle {
        background: Rectangle {
            radius: 2
            color: "darkgray"
            border.color: "gray"
            border.width: 1
            implicitWidth: progressBarRoot.width
            implicitHeight: Units.gu(0.5)
        }
        progress: Rectangle {
            id: progressRect
            color: progressBarColor
            border.color: progressBarColor
        }
    }
}

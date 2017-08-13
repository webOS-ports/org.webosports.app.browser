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

import QtQuick 2.6

import QtQuick.Controls 2.0
import QtQuick.Controls.LuneOS 2.0

import LunaNext.Common 0.1

Menu {
    id: menuRoot

    width: Units.gu(23)
    background: Rectangle {
        radius: Units.gu(0.4)
        color: "#313131"
    }
    signal settingsMenuItem

    MenuItem {
        height:Units.gu(4)
        text: "Preferences..."
        darkTheme: true
        onTriggered: settingsMenuItem();
    }
}

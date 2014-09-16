/*
 * Copyright (C) 2014 Morgan McMillian <gilag@monkeystew.com>
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
import QtQuick.Window 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import LunaNext.Common 0.1

Item {
    id: authDialog

    anchors.fill: parent

    Rectangle {
        id: dimBackground
        anchors.fill: parent
        color: "black"
        opacity: 0.7
    }

    Rectangle {
        id: dialogWindow
        width: Units.gu(45)
        height: Units.gu(25)
        color: "#efefef"

        smooth: true
        radius: 4
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10

        Item {
            id: dialogHeader
            anchors.centerIn: parent
            anchors.fill: parent
            anchors.margins: 10

            Text {
                id: titleText
                width: parent.width
                text: "Authentication Required"
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("medium")
                font.weight: Font.Bold
            }

            Text {
                id: messageText
                width: dialogHeader.width
                text: "A username and password are being requested by the site"
                horizontalAlignment: Text.AlignHCenter
                anchors.top: titleText.bottom
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("medium")
            }

            Rectangle {
                id: rect1
                width: dialogHeader.width
                height: Units.gu(3)
                anchors.top: messageText.bottom
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#dfdfdf"
            }

            Text {
                id: usernameHint
                width: dialogHeader.width
                text: "Username..."
                anchors.verticalCenter: rect1.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.7
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("medium")
            }

            TextInput {
                id: username
                width: dialogHeader.width
                anchors.verticalCenter: rect1.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 5
                clip: true
                anchors.horizontalCenter: parent.horizontalCenter
                focus: true
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("medium")

                onTextChanged: {
                    if (username.length > 0)
                        usernameHint.visible = false
                    else
                        usernameHint.visible = true
                }
            }

            Rectangle {
                id: rect2
                width: dialogHeader.width
                height: Units.gu(3)
                anchors.top: username.bottom
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#dfdfdf"
            }

            Text {
                id: passwordHint
                width: dialogHeader.width
                text: "Password..."
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: rect2.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.7
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("medium")
            }

            TextInput {
                id: password
                width: dialogHeader.width
                anchors.left: parent.left
                anchors.leftMargin: 5
                echoMode: TextInput.Password
                clip: true
                anchors.verticalCenter: rect2.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("medium")

                onTextChanged: {
                    if (password.length > 0)
                        passwordHint.visible = false
                    else
                        passwordHint.visible = true
                }
            }

            Row {
                id: buttonRow
                anchors.right: parent.right
                anchors.left: parent.left
                spacing: 5
                anchors.top: password.bottom
                anchors.topMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    id: cancelButton
                    width: Units.gu(21)
                    height: Units.gu(5)
                    color: "#cacaca"
                    smooth: true
                    radius: 4

                    Text {
                        color: "#2f2f2f"
                        text: "Cancel"
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: model.reject()
                    }
                }

                Rectangle {
                    id: confirmButton
                    width: Units.gu(21)
                    height: Units.gu(5)
                    color: "#555656"
                    smooth: true
                    radius: 4

                    Text {
                        color: "#f2f2f2"
                        text: "OK"
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: model.accept(username.text, password.text)
                    }
                }
            }

        }
    }
}

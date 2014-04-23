/*
 * Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies)
 * Copyright (C) 2010 University of Szeged
 * Copyright (c) 2012 Hewlett-Packard Development Company, L.P.
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import QtQuick 2.0
import LunaNext.Common 0.1

Rectangle {
    id: findBar

    property Item webView
    property Item navigationBar

    z: webView.z + 1
    y: navigationBar.y
    anchors {
        left: parent.left
        right: parent.right
    }
    height: navigationBar.height
    color: "#efefef"
    visible: y > navigationBar.y

    Behavior on y {NumberAnimation {duration: 250}}

    function toggle() {
        if (y == navigationBar.y) {
            findTextInput.forceActiveFocus()
            y += height
        } else {
            webView.forceActiveFocus()
            y = navigationBar.y
            find("",0);
        }
    }

    function find(str, options) {
        var findOptions = options | WebViewExperimental.FindHighlightAllOccurrences
        findOptions |= WebViewExperimental.FindWrapsAroundDocument
        webView.experimental.findText(str, findOptions)
    }

    Connections {
        target: webView.experimental
        onTextFound: {
            failedOverlay.visible = matchCount == 0
        }
    }
    Item {
        anchors.fill: parent
        Rectangle {
            id: inputArea
            height: 26
            anchors {
                left: parent.left
                right: prevButton.left
                margins: 6
                verticalCenter: parent.verticalCenter
            }
            color: "white"
            border.width: 1
            border.color: "#bfbfbf"
            radius: 3
            Rectangle {
                id: failedOverlay
                anchors.fill: parent
                color: "red"
                opacity: 0.5
                radius: 6
                visible: false
            }
            TextInput {
                id: findTextInput
                clip: true
                selectByMouse: true
                horizontalAlignment: TextInput.AlignLeft
                anchors.fill: parent
                anchors.margins: 3
                font {
                    pointSize: 11
                    family: "Sans"
                }
                text: ""
                readOnly: !findBar.visible
                function doFind() {
                    if (!findBar.visible) {
                        return;
                    }
                    if (findTextInput.text == "") {
                        failedOverlay.visible = false
                    }
                    findBar.find(findTextInput.text)
                }
                onTextChanged: {
                    doFind()
                }
                Keys.onReturnPressed:{
                    doFind()
                }
            }
        }
        Rectangle {
            id: prevButton
            height: inputArea.height
            width: height
            anchors.right: nextButton.left
            anchors.verticalCenter: parent.verticalCenter
            color: "#efefef"
            radius: 6

            Image {
                anchors.centerIn: parent
                source: "../icons/previous.png"
            }

            Rectangle {
                anchors.fill: parent
                color: parent.color
                radius: parent.radius
                opacity: 0.8
                visible: !parent.enabled
            }

            MouseArea {
                anchors.fill: parent
                onPressed: { if (parent.enabled) parent.color = "#cfcfcf" }
                onReleased: { parent.color = "#efefef" }
                onClicked: {
                    findBar.find(findTextInput.text, WebViewExperimental.FindBackward)
                }
            }
        }
        Rectangle {
            id: nextButton
            height: inputArea.height
            width: height
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            color: "#efefef"
            radius: 6

            Image {
                anchors.centerIn: parent
                source: "../icons/next.png"
            }

            Rectangle {
                anchors.fill: parent
                color: parent.color
                radius: parent.radius
                opacity: 0.8
                visible: !parent.enabled
            }

            MouseArea {
                anchors.fill: parent
                onPressed: { if (parent.enabled) parent.color = "#cfcfcf" }
                onReleased: { parent.color = "#efefef" }
                onClicked: {
                    findBar.find(findTextInput.text, 0)
                }
            }
        }
    }
}


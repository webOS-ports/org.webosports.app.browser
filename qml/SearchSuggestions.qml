/*
* Copyright (C) 2014 Simon Busch <morphis@gravedo.de>
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
import QtQuick.Window 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import LunaNext.Common 0.1
import "js/util.js" as EnyoUtils

Rectangle {
    property string searchResultsAll: "{}"
    property string optSearchText: ""
    property string defaultSearchIcon: ""
    property int urlModelCount: 0
    property int suggestionListHeight: 0
    color: "#DADADA"
    radius: 4
    visible: false
    height: (urlModel.count + 1) * Units.gu(6)

    function show() {
        visible = true;
    }
    function hide() {
        visible = false;
    }

    Rectangle {
        id: searchRect
        height: Units.gu(6)
        width: parent.width
        anchors.left: parent.left
        color: "transparent"
        z: 3

        MouseArea {
            anchors.fill: parent
            onPressed: {
                searchSuggestions.visible = false
                webViewItem.url = defaultSearchURL.replace("#{searchTerms}",
                                                           addressBarItem.addressBarText)
                addressBarItem.addressBarText = defaultSearchURL.replace("#{searchTerms}",
                                                           addressBarItem.addressBarText)
            }
        }

        Text {
            id: optSearch
            text: searchSuggestions.optSearchText + " \"" + addressBarItem.addressBarText + "\""
            width: searchRect.width - Units.gu(7)
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: Units.gu(2)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: FontUtils.sizeToPixels("large")
            font.family: "Prelude"
            color: "#494949"
            height: Units.gu(6)
            elide: Text.ElideRight
            z: 3
        }
        Rectangle {
            id: imgSearchRect
            height: urlModel.count > 0 ? parent.height : 0
            anchors.right: parent.right
            z: 3
            Image {
                id: imgSearch
                height: Units.gu(3)
                width: Units.gu(3)
                anchors.top: imgSearchRect.top
                anchors.topMargin: Units.gu(1.5)
                anchors.right: parent.right
                anchors.rightMargin: Units.gu(1.5)
                horizontalAlignment: Image.AlignRight
                source: searchSuggestions.defaultSearchIcon
                z: 3
            }
        }
        Rectangle {
            id: searchDivider
            color: "silver"

            width: parent.width
            height: urlModel.count > 0 ? Units.gu(1 / 5) : 0
            anchors.top: imgSearchRect.bottom
            z: 3
        }
    }
    ListView {
        anchors.top: searchRect.bottom
        id: suggestionList
        width: parent.width
        z: 2
        height: suggestionListHeight

        JSONListModel {
            id: urlModel
            json: getURLHistory()
            query: "$[*]"

            function getURLHistory() {
                return searchResultsAll
            }
        }
        model: urlModel.model

        delegate: Rectangle {
            id: sectionRect
            height: Units.gu(6)
            width: parent.width
            anchors.left: parent.left
            color: "transparent"
            z: 2

            Text {
                id: urlTitle
                anchors.top: sectionRect.top
                anchors.topMargin: Units.gu(0.75)
                height: sectionRect.height
                clip: true
                width: sectionRect.width - Units.gu(7)
                anchors.left: sectionRect.left
                anchors.leftMargin: Units.gu(2)
                horizontalAlignment: Text.AlignLeft
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("large")
                color: "#494949"
                textFormat: Text.RichText
                text: EnyoUtils.applyFilterHighlight(model.title,
                                                     addressBarItem.addressBarText)
                z: 2
                Text {
                    height: parent.height
                    clip: true
                    id: url
                    width: parent.width
                    anchors.top: urlTitle.top
                    anchors.topMargin: Units.gu(0.75)
                    verticalAlignment: Text.AlignVCenter
                    anchors.left: parent.left
                    horizontalAlignment: Text.AlignLeft
                    font.family: "Prelude"
                    font.pixelSize: FontUtils.sizeToPixels("small")
                    textFormat: Text.RichText
                    text: EnyoUtils.applyFilterHighlight(model.url,
                                                         addressBarItem.addressBarText)
                    color: "#838383"
                    z: 2
                }
            }
            Rectangle {
                color: "silver"
                height: Units.gu(1 / 10)
                width: parent.width
                anchors.top: parent.top
                z: 2
            }

            Rectangle {
                id: imgResultsRect
                height: Units.gu(6)
                anchors.right: parent.right
                anchors.top: sectionRect.top
                z: 2

                Image {
                    source: model.icon64 ? model.icon64: model.icon
                    anchors.top: imgResultsRect.top
                    anchors.right: parent.right
                    height: Units.gu(3)
                    width: Units.gu(3)
                    anchors.topMargin: Units.gu(1.5)
                    anchors.rightMargin: Units.gu(1)
                    horizontalAlignment: Image.AlignRight
                    z: 2
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    searchSuggestions.visible = false
                    webViewItem.url = model.url
                    addressBarItem.addressBarText = model.url
                }
            }
            Component.onCompleted: {
                urlModelCount = urlModel.count
                searchSuggestions.height = (urlModel.count + 1) * Units.gu(
                            6)
                suggestionList.height = (urlModel.count) * Units.gu(6)
            }
            Component.onDestruction: {
                urlModelCount = urlModel.count
                searchSuggestions.height = (urlModel.count + 1) * Units.gu(
                            6)
                suggestionList.height = (urlModel.count) * Units.gu(6)

            }
        }
    }
}

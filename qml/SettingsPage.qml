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
import QtQuick.Window 2.1
import LunaNext.Common 0.1

Rectangle {
    id: root
    color: "#e5e5e5"

    signal closePage
    signal showPage
    property bool enableDebugOutput: true
    property bool blockPopups: true
    property bool enableJavascript: true
    property bool enablePlugins: true
    property bool rememberPasswords: true
    property var defaultBrowserPreferences
    property var searchProviderResults
    property string searchProvidersAll: "{}"
    property string dbmode: ""
    property string defaultSearchProvider: ""
    property string defaultSearchProviderURL: ""
    property string defaultSearchProviderIcon: ""
    property string defaultSearchProviderDisplayName: ""

    MouseArea {
        anchors.fill: parent
    }

    Rectangle {
        id: overlayRect
        color: "#4C4C4C"
        opacity: 0.9
        anchors.fill: parent
        visible: false
        z: 1
    }

    onShowPage: {
        _initDialog()
        root.visible = true
        Qt.inputMethod.hide()
    }
    onClosePage: {
        //Save the preferences (this probably needs some reworking but it does the trick for now :P)
        dbmode = ""
        __queryDB("merge", '{"props":{"value":' + blockPopups
                  + '},"query":{"from":"com.palm.browserpreferences:1","where":[{"prop":"key","op":"=","val":"blockPopups"}]}}')
        __queryDB("merge", '{"props":{"value":' + enableJavascript
                  + '},"query":{"from":"com.palm.browserpreferences:1","where":[{"prop":"key","op":"=","val":"enableJavascript"}]}}')
        __queryDB("merge", '{"props":{"value":' + enablePlugins
                  + '},"query":{"from":"com.palm.browserpreferences:1","where":[{"prop":"key","op":"=","val":"enablePlugins"}]}}')
        __queryDB("merge", '{"props":{"value":' + rememberPasswords
                  + '},"query":{"from":"com.palm.browserpreferences:1","where":[{"prop":"key","op":"=","val":"rememberPasswords"}]}}')

        luna.call("luna://com.palm.universalsearch/setSearchPreference", '{"key":"defaultSearchEngine", "value": "'+defaultSearchProvider+'"}', __handleSPSuccess, __handleSPError)

        //Make sure we update the search engine as well
        navigationBar.defaultSearchURL = defaultSearchProviderURL
        navigationBar.defaultSearchIcon = defaultSearchProviderIcon
        navigationBar.defaultSearchDisplayName = defaultSearchProviderDisplayName

        root.visible = false
    }

    function __handleSPError(message) {
        console.log("Could change Default Search Engine : " + message)
    }

    function __handleSPSuccess(message) {
        if (root.enableDebugOutput) {
            console.log("Successfully changed Default Search Engine : " + message)
        }
    }


    function __queryDB(action, params) {
        if (root.enableDebugOutput) {
            console.log("Querying DB with action: " + action + " and params: " + params)
        }
        luna.call("luna://com.palm.db/" + action, params,
                  __handleQueryDBSuccess, __handleQueryDBError)
    }

    function __handleQueryDBError(message) {
        console.log("Could not query prefs DB : " + message)
    }

    function __handleQueryDBSuccess(message) {
        if (root.enableDebugOutput) {
            console.log("Queried Prefs DB : " + JSON.stringify(message.payload))
        }
        if (dbmode === "prefs") {
            //TODO: Far from pretty but it works
            defaultBrowserPreferences = JSON.parse(message.payload)
            for (var j = 0, t; t = defaultBrowserPreferences.results[j]; j++) {
                if (t.key === "blockPopups") {
                    blockPopups = t.value
                } else if (t.key === "enableJavascript") {
                    enableJavascript = t.value
                } else if (t.key === "enablePlugins") {
                    enablePlugins = t.value
                } else if (t.key === "rememberPasswords") {
                    rememberPasswords = t.value
                }
            }
        } else {
            console.log("Nothing to do for this dbmode: " + dbmode)
        }
    }

    function _initDialog() {
        // get the setting values, and fill in the parameters of the dialog
        dbmode = "prefs"
        __queryDB("find", '{"query":{"from":"com.palm.browserpreferences:1"}}')

        //Query Search Providers on loading
        __querySearchProviders()

    }

    function clearItems(clearMode) {
        if (clearMode === "history") {
            dbmode = "history"
            __queryDB(
                        "del", '{"query":{"from":"com.palm.browserhistory:1"}}')
        } else if (clearMode === "bookmarks") {
            dbmode = "bookmarks"
            __queryDB(
                        "del",
                        '{"query":{"from":"com.palm.browserbookmarks:1"}}')
        }
    }

    function __querySearchProviders(action, params) {
        if (root.enableDebugOutput) {
            console.log("Querying SearchProviders")
        }
        luna.call("luna://com.palm.universalsearch/getUniversalSearchList", JSON.stringify({}),
                  __handleQuerySearchProviderSuccess, __handleQuerySearchProviderError)
    }

    function __handleQuerySearchProviderError(message) {
        console.log("Could not query search providers : " + message)
    }

    function __handleQuerySearchProviderSuccess(message) {
        if (root.enableDebugOutput) {
            console.log("Queried search providers : " + JSON.stringify(message.payload))
        }

        searchProviderResults = JSON.parse(message.payload)

        //Stringify the UniversalSearchList so we can use it in the JSONList
        searchProvidersAll = JSON.stringify(searchProviderResults.UniversalSearchList);
        return searchProvidersAll
    }


    Rectangle {
        id: header
        width: parent.width
        height: Units.gu(7)
        color: "transparent"

        Image {
            id: headerBG
            source: "images/header.png"
            fillMode: Image.TileHorizontally
            anchors.fill: parent

            Image {
                id: headerImage
                height: Units.gu(6)
                width: Units.gu(6)
                anchors.left: parent.left
                anchors.leftMargin: (header.width / 2) - (headerText.width / 2) - Units.gu(
                                        3)
                anchors.verticalCenter: parent.verticalCenter
                source: "images/header-icon-prefs.png"
            }
            Text {
                id: headerText
                text: "Preferences"
                font.family: "Prelude"
                color: "#444444"
                font.pixelSize: FontUtils.sizeToPixels("large")
                anchors.left: headerImage.right
                anchors.leftMargin: Units.gu(1)
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Rectangle {
        id: searchPrefsOutside
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: header.bottom
        anchors.topMargin: Units.gu(3)
        width: Screen.width >= 900 ? Screen.width / 4 : (Screen.width * 2 / 3)
        height: Units.gu(7)
        color: "#A2A2A2"
        radius: 10

        Text {
            text: "DEFAULT WEB SEARCH ENGINE"
            font.family: "Prelude"
            font.bold: true
            font.pixelSize: FontUtils.sizeToPixels("small")
            color: "white"
            anchors.top: searchPrefsOutside.top
            anchors.topMargin: Units.gu(1 / 2)
            anchors.left: searchPrefsOutside.left
            anchors.leftMargin: Units.gu(1)
        }
        Rectangle {
            id: searchPrefsInside
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: searchPrefsOutside.bottom
            anchors.bottomMargin: 1
            width: Screen.width >= 900 ? (Screen.width / 4 - 2) : ((Screen.width * 2 / 3) - 2)
            height: searchPrefsOutside.height - Units.gu(3)
            color: "#D8D8D8"
            radius: 10

            Text {
                id: searchPrefsText
                anchors.left: parent.left
                anchors.leftMargin: Units.gu(1)
                anchors.verticalCenter: parent.verticalCenter
                text: navigationBar.defaultSearchDisplayName
                font.family: "Prelude"
                color: "#444444"
                font.pixelSize: FontUtils.sizeToPixels("medium")
            }
            Image
            {
                id: searchPrefsImage
                source: "images/menu-arrow.png"
                anchors.right: parent.right
                anchors.rightMargin: Units.gu(1)
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea
            {
                anchors.fill: parent
                onPressed:
                {
                    searchProviderList.visible = true
                }
            }


        }
    }

    ListView {
        id: searchProviderList
        anchors.top: searchPrefsOutside.bottom
        anchors.right: searchPrefsOutside.right
        anchors.rightMargin: Units.gu(1) + searchPrefsImage.width / 2
        width: Units.gu(18)
        height: Units.gu(30)
        visible: false
        z: 500

        Rectangle
        {
            anchors.fill: parent
            radius: 6
            border.width: Units.gu(1/10)
            border.color: "#7D7D7D"
            color: "transparent"
            z: 500
        }

        JSONListModel {
            id: searchProviderModel
            json: getSearchProviders()
            //We only want the enabled search engines, seems there are some disabled ones too
            query: "$[?(@.enabled == true)]"

            function getSearchProviders()
            {
                return searchProvidersAll
            }

        }
        model: searchProviderModel.model

        delegate: Rectangle {
            id: sectionRect
            height: Units.gu(5)
            width: parent.width
            anchors.left: parent.left
            color: "#D9D9D9"

            Text {
                id: searchProviderName
                height: sectionRect.height
                clip: true
                width: sectionRect.width
                anchors.left: sectionRect.left
                anchors.leftMargin: Units.gu(2)
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("medium")
                color: "#494949"
                text: model.displayName
            }
           Image {
                id: defaultSearchProviderImage
                anchors.right: searchProviderName.right
                anchors.rightMargin: Units.gu(3)
                anchors.verticalCenter: parent.verticalCenter
                source: searchPrefsText.text === model.displayName ? "images/checkmark.png" : ""
            }
            Rectangle {
                color: "silver"
                height: Units.gu(1 / 10)
                width: parent.width
                anchors.top: parent.top
                z: 2
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    searchPrefsText.text = model.displayName
                    defaultSearchProvider = model.id
                    defaultSearchProviderURL = model.url
                    defaultSearchProviderIcon = model.iconFilePath
                    defaultSearchProviderDisplayName = model.displayName
                    searchProviderList.visible = false
                }
            }

            Component.onCompleted:
            {
                searchProviderList.height = (searchProviderModel.count) * sectionRect.height
            }
        }
    }

    Rectangle {
        id: browserPrefsOutside
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: searchPrefsOutside.bottom
        anchors.topMargin: Units.gu(1.5)
        width: Screen.width >= 900 ? Screen.width / 4 : (Screen.width * 2 / 3)
        height: Units.gu(27.6)
        color: "#A2A2A2"
        radius: 10

        Text {
            text: "CONTENT"
            font.family: "Prelude"
            font.bold: true
            font.pixelSize: FontUtils.sizeToPixels("small")
            color: "white"
            anchors.top: browserPrefsOutside.top
            anchors.topMargin: Units.gu(1 / 2)
            anchors.left: browserPrefsOutside.left
            anchors.leftMargin: Units.gu(1)
        }
        Rectangle {
            id: browserPrefsInside
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: browserPrefsOutside.bottom
            anchors.bottomMargin: 1
            width: Screen.width >= 900 ? (Screen.width / 4 - 2) : ((Screen.width * 2 / 3) - 2)
            height: browserPrefsOutside.height - Units.gu(3)
            color: "#D8D8D8"
            radius: 10
            Rectangle {
                id: blockPopupsRect
                width: parent.width
                height: Units.gu(6)
                color: "transparent"
                anchors.left: parent.left
                Text {
                    id: blockPopupsText
                    anchors.left: parent.left
                    anchors.leftMargin: Units.gu(1)
                    text: "Block Popups"
                    color: "#444444"
                    font.family: "Prelude"
                    font.pixelSize: FontUtils.sizeToPixels("medium")
                    anchors.verticalCenter: parent.verticalCenter
                }
                Image {
                    id: blockPopupsToggleOff
                    anchors.verticalCenter: parent.verticalCenter
                    source: "images/toggle-button-off.png"
                    anchors.right: parent.right
                    anchors.rightMargin: Units.gu(1)
                    height: Units.gu(4)
                    width: Units.gu(8)

                    visible: blockPopups ? false : true
                    MouseArea {
                        anchors.fill: parent
                        onPressed: {
                            blockPopups = true
                            blockPopupsToggleOn.visible = true
                            blockPopupsToggleOff.visible = false
                        }
                    }
                    Text {
                        anchors.left: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        text: "OFF"
                        font.bold: true
                        font.family: "Prelude"
                        font.pixelSize: FontUtils.sizeToPixels("small")
                    }
                }
                Image {
                    id: blockPopupsToggleOn
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: Units.gu(1)
                    source: "images/toggle-button-on.png"
                    height: Units.gu(4)
                    width: Units.gu(8)
                    anchors.right: parent.right
                    visible: blockPopups ? true : false
                    MouseArea {
                        anchors.fill: parent
                        onPressed: {
                            blockPopups = false
                            blockPopupsToggleOn.visible = false
                            blockPopupsToggleOff.visible = true
                        }
                    }
                    Text {
                        anchors.right: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        text: "ON"
                        font.bold: true
                        font.family: "Prelude"
                        font.pixelSize: FontUtils.sizeToPixels("small")
                    }
                }
            }
            Rectangle {
                id: browserPrefsDivider1
                color: "silver"
                width: parent.width
                height: Units.gu(1 / 5)
                anchors.top: blockPopupsRect.bottom
            }
            Rectangle {
                id: enableJavascriptRect
                width: parent.width
                height: Units.gu(6)
                color: "transparent"
                anchors.top: browserPrefsDivider1.bottom
                anchors.left: parent.left
                Text {
                    id: enableJavascriptText
                    anchors.left: parent.left
                    anchors.leftMargin: Units.gu(1)
                    text: "Enable JavaScript"
                    color: "#444444"
                    font.family: "Prelude"
                    font.pixelSize: FontUtils.sizeToPixels("medium")
                    anchors.verticalCenter: parent.verticalCenter
                }
                Image {
                    id: enableJavascriptToggleOff
                    anchors.verticalCenter: parent.verticalCenter
                    source: "images/toggle-button-off.png"
                    anchors.right: parent.right
                    anchors.rightMargin: Units.gu(1)
                    visible: enableJavascript ? false : true
                    height: Units.gu(4)
                    width: Units.gu(8)

                    MouseArea {
                        anchors.fill: parent
                        onPressed: {
                            enableJavascript = true
                            enableJavascriptToggleOn.visible = true
                            enableJavascriptToggleOff.visible = false
                        }
                    }
                    Text {
                        anchors.left: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        text: "OFF"
                        font.bold: true
                        font.family: "Prelude"
                        font.pixelSize: FontUtils.sizeToPixels("small")
                    }
                }
                Image {
                    id: enableJavascriptToggleOn
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: Units.gu(1)
                    source: "images/toggle-button-on.png"
                    anchors.right: parent.right
                    visible: enableJavascript ? true : false
                    height: Units.gu(4)
                    width: Units.gu(8)

                    MouseArea {
                        anchors.fill: parent
                        onPressed: {
                            enableJavascript = false
                            enableJavascriptToggleOn.visible = false
                            enableJavascriptToggleOff.visible = true
                        }
                    }
                    Text {
                        anchors.right: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        text: "ON"
                        font.bold: true
                        font.family: "Prelude"
                        font.pixelSize: FontUtils.sizeToPixels("small")
                    }
                }
                Rectangle {
                    id: browserPrefsDivider2
                    color: "silver"
                    width: parent.width
                    height: Units.gu(1 / 5)
                    anchors.top: enableJavascriptRect.bottom
                }

                Rectangle {
                    id: enablePluginsRect
                    width: parent.width
                    height: Units.gu(6)
                    color: "transparent"
                    anchors.top: browserPrefsDivider2.bottom
                    anchors.left: parent.left
                    Text {
                        id: enablePluginsText
                        anchors.left: parent.left
                        anchors.leftMargin: Units.gu(1)
                        text: "Enable Plugins"
                        font.family: "Prelude"
                        color: "#444444"
                        font.pixelSize: FontUtils.sizeToPixels("medium")
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Image {
                        id: enablePluginsToggleOff
                        anchors.verticalCenter: parent.verticalCenter
                        source: "images/toggle-button-off.png"
                        anchors.right: parent.right
                        anchors.rightMargin: Units.gu(1)
                        visible: enablePlugins ? false : true
                        height: Units.gu(4)
                        width: Units.gu(8)

                        MouseArea {
                            anchors.fill: parent
                            onPressed: {
                                enablePlugins = true
                                enablePluginsToggleOn.visible = true
                                enablePluginsToggleOff.visible = false
                            }
                        }
                        Text {
                            anchors.left: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            color: "white"
                            text: "OFF"
                            font.bold: true
                            font.family: "Prelude"
                            font.pixelSize: FontUtils.sizeToPixels("small")
                        }
                    }
                    Image {
                        id: enablePluginsToggleOn
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: Units.gu(1)
                        source: "images/toggle-button-on.png"
                        anchors.right: parent.right
                        visible: enablePlugins ? true : false
                        height: Units.gu(4)
                        width: Units.gu(8)

                        MouseArea {
                            anchors.fill: parent
                            onPressed: {
                                enablePlugins = false
                                enablePluginsToggleOn.visible = false
                                enablePluginsToggleOff.visible = true
                            }
                        }
                        Text {
                            anchors.right: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            color: "white"
                            text: "ON"
                            font.bold: true
                            font.family: "Prelude"
                            font.pixelSize: FontUtils.sizeToPixels("small")
                        }
                    }
                }
                Rectangle {
                    id: browserPrefsDivider3
                    color: "silver"
                    width: parent.width
                    height: Units.gu(1 / 5)
                    anchors.top: enablePluginsRect.bottom
                }

                Rectangle {
                    id: rememberPasswordsRect
                    width: parent.width
                    height: Units.gu(6)
                    color: "transparent"
                    anchors.top: browserPrefsDivider3.bottom
                    anchors.left: parent.left
                    Text {
                        id: rememberPasswordsText
                        anchors.left: parent.left
                        anchors.leftMargin: Units.gu(1)
                        text: "Remember Passwords"
                        color: "#444444"
                        font.family: "Prelude"
                        font.pixelSize: FontUtils.sizeToPixels("medium")
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Image {
                        id: rememberPasswordsToggleOff
                        anchors.verticalCenter: parent.verticalCenter
                        source: "images/toggle-button-off.png"
                        anchors.right: parent.right
                        anchors.rightMargin: Units.gu(1)
                        visible: rememberPasswords ? false : true
                        height: Units.gu(4)
                        width: Units.gu(8)

                        MouseArea {
                            anchors.fill: parent
                            onPressed: {
                                rememberPasswords = true
                                rememberPasswordsToggleOn.visible = true
                                rememberPasswordsToggleOff.visible = false
                            }
                        }
                        Text {
                            anchors.left: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            color: "white"
                            text: "OFF"
                            font.bold: true
                            font.family: "Prelude"
                            font.pixelSize: FontUtils.sizeToPixels("small")
                        }
                    }
                    Image {
                        id: rememberPasswordsToggleOn
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: Units.gu(1)
                        source: "images/toggle-button-on.png"
                        anchors.right: parent.right
                        visible: rememberPasswords ? true : false
                        height: Units.gu(4)
                        width: Units.gu(8)

                        MouseArea {
                            anchors.fill: parent
                            onPressed: {
                                rememberPasswords = false
                                rememberPasswordsToggleOn.visible = false
                                rememberPasswordsToggleOff.visible = true
                            }
                        }
                        Text {
                            anchors.right: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            color: "white"
                            text: "ON"
                            font.bold: true
                            font.family: "Prelude"
                            font.pixelSize: FontUtils.sizeToPixels("small")
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: clearBookmarksButton
        anchors.top: browserPrefsOutside.bottom
        anchors.topMargin: Units.gu(1.5)
        anchors.horizontalCenter: parent.horizontalCenter
        width: Screen.width >= 900 ? Screen.width / 4 : (Screen.width * 2 / 3)
        height: Units.gu(4)
        radius: 4
        color: "transparent"
        MouseArea {
            anchors.fill: parent
            onPressed: {
                overlayRect.visible = true
                popupConfirm.visible = true
                popupConfirm.buttonText = "Would you like to clear your bookmarks?"
                popupConfirm.clearMode = "bookmarks"
            }
        }

        Image {
            id: clearBookmarksButtonImageLeft
            source: "images/button-up-left.png"
            anchors.left: parent.left
            height: parent.height
        }

        Image {
            id: clearBookmarksButtonImageCenter
            source: "images/button-up-center.png"
            fillMode: Image.Stretch
            anchors.left: clearBookmarksButtonImageLeft.right
            anchors.right: clearBookmarksButtonImageRight.left
            height: parent.height
        }

        Image {
            id: clearBookmarksButtonImageRight
            source: "images/button-up-right.png"
            anchors.right: parent.right
            height: parent.height
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#292929"
            text: "Clear Bookmarks"
            font.family: "Prelude"
            font.pixelSize: FontUtils.sizeToPixels("medium")
        }
    }

    Rectangle {
        id: clearHistoryButton
        anchors.top: clearBookmarksButton.bottom
        anchors.topMargin: Units.gu(0.75)
        anchors.horizontalCenter: parent.horizontalCenter
        width: Screen.width >= 900 ? Screen.width / 4 : (Screen.width * 2 / 3)
        height: Units.gu(4)
        radius: 4
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onPressed: {
                overlayRect.visible = true
                popupConfirm.visible = true
                popupConfirm.buttonText = "Would you like to clear your browser history?"
                popupConfirm.clearMode = "history"
            }
        }

        Image {
            id: clearHistoryButtonImageLeft
            source: "images/button-up-left.png"
            anchors.left: parent.left
            height: parent.height
        }

        Image {
            id: clearHistoryButtonImageCenter
            source: "images/button-up-center.png"
            fillMode: Image.Stretch
            anchors.left: clearHistoryButtonImageLeft.right
            anchors.right: clearHistoryButtonImageRight.left
            height: parent.height
        }

        Image {
            id: clearHistoryButtonImageRight
            source: "images/button-up-right.png"
            anchors.right: parent.right
            height: parent.height
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#292929"
            text: "Clear History"
            font.family: "Prelude"
            font.pixelSize: FontUtils.sizeToPixels("medium")
        }
    }

    ConfirmDialog
    {
        id: popupConfirm
    }

    Rectangle {
        id: footer
        height: Units.gu(7)
        width: parent.width
        color: "transparent"
        anchors.bottom: parent.bottom
        Image {
            anchors.fill: parent
            id: footerBG
            source: "images/toolbar-light.png"
            fillMode: Image.TileHorizontally

            Rectangle {
                id: footerButton
                width: Screen.width >= 900 ? Screen.width / 4 : (Screen.width * 2 / 3)
                height: Units.gu(5)
                radius: 4
                color: "#4B4B4B"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                Image {
                    id: footerButtonImageLeft
                    source: "images/button-up-left.png"
                    anchors.left: parent.left
                    height: parent.height
                }

                Image {
                    id: footerButtonImageCenter
                    source: "images/button-up-center.png"
                    fillMode: Image.Stretch
                    anchors.left: footerButtonImageLeft.right
                    anchors.right: footerButtonImageRight.left
                    height: parent.height
                }

                Image {
                    id: footerButtonImageRight
                    source: "images/button-up-right.png"
                    anchors.right: parent.right
                    height: parent.height
                }

                Text {
                    id: footerButtonText
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: "Prelude"
                    color: "white"
                    text: "Done"
                    font.bold: true
                    font.pixelSize: FontUtils.sizeToPixels("small")
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed:
                    {
                        closePage()
                    }
                }
            }
        }
    }
}

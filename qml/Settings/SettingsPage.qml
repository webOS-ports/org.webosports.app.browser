/*
* Copyright (C) 2014-2016 Christophe Chapuis <chris.chapuis@gmail.com>
* Copyright (C) 2014-2016 Herman van Hazendonk <github.com@herrie.org>
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
import LuneOS.Service 1.0

import "../Models"
import "../Utils"

Page {
    id: root

    property bool enableDebugOutput: false
    property alias blockPopups: blockPopupsToggle.checked
    property alias enableJavascript: enableJavascriptToggle.checked
    property alias enablePlugins: enablePluginsToggle.checked
    property alias rememberPasswords: rememberPasswordsToggle.checked
    property alias acceptCookies: acceptCookiesToggle.checked
    property var defaultBrowserPreferences
    property var searchProviderResults
    property string searchProvidersAll: "{}"
    property string defaultSearchProvider: ""
    property string defaultSearchProviderURL: ""
    property string defaultSearchProviderIcon: ""
    property string defaultSearchProviderDisplayName: ""

    property BookmarkDbModel  bookmarkDbModel
    property HistoryDbModel   historyDbModel

    signal closePage()
    signal showPage()
    signal applyNewPreferences(string defaultSearchURL, string defaultSearchIcon, string defaultSearchDisplayName, bool enableJavascript, bool blockPopups, bool enablePlugins, bool rememberPasswords, bool acceptCookies)

    LunaService {
        id: luna
        name: "org.webosports.app.browser"
    }

    onShowPage: {
        _initDialog()
        root.visible = true
        Qt.inputMethod.hide()
    }
    onClosePage: {
        //Save the preferences (this probably needs some reworking but it does the trick for now :P)
        __mergeDB('{"props":{"value":' + blockPopups
                  + '},"query":{"from":"com.palm.browserpreferences:1","where":[{"prop":"key","op":"=","val":"blockPopups"}]}}')
        __mergeDB('{"props":{"value":' + enableJavascript
                  + '},"query":{"from":"com.palm.browserpreferences:1","where":[{"prop":"key","op":"=","val":"enableJavascript"}]}}')
        __mergeDB('{"props":{"value":' + enablePlugins
                  + '},"query":{"from":"com.palm.browserpreferences:1","where":[{"prop":"key","op":"=","val":"enablePlugins"}]}}')
        __mergeDB('{"props":{"value":' + rememberPasswords
                  + '},"query":{"from":"com.palm.browserpreferences:1","where":[{"prop":"key","op":"=","val":"rememberPasswords"}]}}')

        luna.call("luna://com.palm.universalsearch/setSearchPreference", '{"key":"defaultSearchEngine", "value": "'+defaultSearchProvider+'"}', __handleSPSuccess, __handleSPError)

        //Make sure we update the search engine as well
        applyNewPreferences(defaultSearchProviderURL, defaultSearchProviderIcon, defaultSearchProviderDisplayName, enableJavascript, blockPopups, enablePlugins, rememberPasswords, acceptCookies);
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


    function __findDB(params) {
        if (root.enableDebugOutput) {
            console.log("Querying DB with action: " + action + " and params: " + params)
        }
        luna.call("luna://com.palm.db/find", params, __handleQueryDBSuccess, __handleQueryDBError)
    }
    function __mergeDB(params) {
        if (root.enableDebugOutput) {
            console.log("Merging DB with action: " + action + " and params: " + params)
        }
        luna.call("luna://com.palm.db/merge", params, undefined, __handleQueryDBError)
    }

    function __handleQueryDBError(message) {
        console.log("Could not query prefs DB : " + message)
    }

    function __handleQueryDBSuccess(message) {
        if (root.enableDebugOutput) {
            console.log("Queried Prefs DB : " + JSON.stringify(message.payload))
        }

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
            } else if (t.key === "acceptCookies") {
                acceptCookies = t.value
            }
        }
    }

    function _initDialog() {
        // get the setting values, and fill in the parameters of the dialog
        __findDB('{"query":{"from":"com.palm.browserpreferences:1"}}')

        //Query Search Providers on loading
        __querySearchProviders()

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

    readonly property real _contentWidth: root.width >= 900 ? root.width / 2 : (root.width * 2 / 3)

    header: Image {
        height: Units.gu(7)
        width: root.width
        source: "../images/toolbar-light.png"
        fillMode: Image.TileHorizontally

        Row {
            height:parent.height
            spacing: Units.gu(1)
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                height: Units.gu(6)
                width: Units.gu(6)
                source: "../images/header-icon-prefs.png"
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "Preferences"
                font.family: "Prelude"
                color: "#444444"
                font.pixelSize: FontUtils.sizeToPixels("large")

                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Column {
        topPadding: Units.gu(2)
        width: _contentWidth
        spacing: Units.gu(3)
        anchors.horizontalCenter: parent.horizontalCenter

        GroupBox {
            id: searchPrefsGroupBox
            width: parent.width

            title: "Default Web Search Engine"

            ComboBox {
                width: parent.width
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
                textRole: "displayName"
                model: searchProviderModel.model
                currentIndex: 0

                onActivated: {
                    defaultSearchProvider = model.get(index).id
                    defaultSearchProviderURL = model.get(index).url
                    defaultSearchProviderIcon = model.get(index).iconFilePath
                    defaultSearchProviderDisplayName = model.get(index).displayName
                }
            }
        }

        GroupBox {
            id: browserPrefsGroupBox
            width: parent.width

            title: "Content"

            Column {
                width: parent.width

                Switch {
                    id: blockPopupsToggle
                    width: parent.width
                    text: "Block Popups"
                    font.weight: Font.Normal
                    LayoutMirroring.enabled: true

                    //mirrored: true
                    LuneOSSwitch.labelOn: "On"
                    LuneOSSwitch.labelOff: "Off"
                }
                Rectangle { color: "silver"; width: parent.width; height: 2 }
                Switch {
                    id: acceptCookiesToggle
                    width: parent.width
                    text: "Accept Cookies"
                    font.weight: Font.Normal
                    LayoutMirroring.enabled: true

                    LuneOSSwitch.labelOn: "On"
                    LuneOSSwitch.labelOff: "Off"
                }
                Rectangle { color: "silver"; width: parent.width; height: 2 }
                Switch {
                    id: enableJavascriptToggle
                    width: parent.width
                    text: "Enable JavaScript"
                    font.weight: Font.Normal
                    LayoutMirroring.enabled: true

                    LuneOSSwitch.labelOn: "On"
                    LuneOSSwitch.labelOff: "Off"
                }
                Rectangle { color: "silver"; width: parent.width; height: 2 }
                Switch {
                    id: enablePluginsToggle
                    width: parent.width
                    text: "Enable Plugins"
                    font.weight: Font.Normal
                    LayoutMirroring.enabled: true

                    LuneOSSwitch.labelOn: "On"
                    LuneOSSwitch.labelOff: "Off"
                }
                Rectangle { color: "silver"; width: parent.width; height: 2 }
                Switch {
                    id: rememberPasswordsToggle
                    width: parent.width
                    text: "Remember Passwords"
                    font.weight: Font.Normal
                    LayoutMirroring.enabled: true

                    LuneOSSwitch.labelOn: "On"
                    LuneOSSwitch.labelOff: "Off"
                }
            }
        }

        Button {
            height: Units.gu(4)
            width: _contentWidth

            text: "Clear Bookmarks"
            LuneOSButton.mainColor: LuneOSButton.secondaryColor

            onClicked: popupConfirmClearBookmarks.open();
        }

        Button {
            height: Units.gu(4)
            width: _contentWidth

            text: "Clear History"
            LuneOSButton.mainColor: LuneOSButton.secondaryColor

            onClicked: popupConfirmClearHistory.open();
        }
    }

    footer: Image {
        height: Units.gu(7)
        width: root.width
        source: "../images/toolbar-light.png"
        fillMode: Image.TileHorizontally

        Button {
            height: Units.gu(5)
            width: _contentWidth
            anchors.centerIn: parent

            text: "Done"

            onClicked: closePage();
        }
    }


    ConfirmDialogCustom
    {
        id: popupConfirmClearHistory

        x: parent.width/2-width/2
        y: parent.height/2-height/2

        width: Math.min(Units.gu(40), parent.width-Units.gu(2));
        height: Units.gu(23)

        title: "Would you like to clear your browser history?"
        buttonText: "Clear History"

        onCommitAction: historyDbModel.clearDB();
    }

    ConfirmDialogCustom
    {
        id: popupConfirmClearBookmarks

        x: parent.width/2-width/2
        y: parent.height/2-height/2

        width: Math.min(Units.gu(40), parent.width-Units.gu(2));
        height: Units.gu(23)

        title: "Would you like to clear your bookmarks?"
        buttonText: "Clear Bookmarks"

        onCommitAction: bookmarkDbModel.clearDB();
    }
}

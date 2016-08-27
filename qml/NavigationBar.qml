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
import QtQuick 2.5
import QtQuick.Window 2.1
import QtQuick.Layouts 1.1

import LuneOS.Service 1.0
import LuneOS.Components 1.0
import LunaNext.Common 0.1
import "js/util.js" as EnyoUtils

import "AppTweaks"

Rectangle {
    id: navigationBar

    property BrowserWebView webView

    signal toggleHistoryPanel();
    signal toggleShareOptionsList();

    property string searchProviderIcon: ""
    property string defaultSearch: ""
    property string defaultSearchURL: ""
    property string defaultSearchIcon: "images/list-icon-google.png"
    property string defaultSearchDisplayName: "Google"
    property bool isSecureSite: false
    property var searchResultsBookmarks
    property var searchResultsHistory

    color: "#343434"

    Component.onCompleted: navigationBar.__getDefaultSearch()

    /////// private //////
    LunaService {
        id: luna
        name: "org.webosports.app.browser"
    }

    function setFocus(focusState) {
        if (appWindow.enableDebugOutput) {
            console.log("setFocus called with" + focusState)
        }
        addressBar.focus = focusState
    }

    function __launchApplication(id, params) {
        if (appWindow.enableDebugOutput) {
            console.log("launching app " + id + " with params " + params)
        }
        luna.call("luna://com.palm.applicationManager/launch", JSON.stringify({
                                                                                  id: id,
                                                                                  params: params
                                                                              }),
                  undefined, __handleLaunchAppError)
    }

    function __handleLaunchAppError(message) {
        console.log("Could not start application : " + message)
    }

    function __queryPutDB(myData) {
        if (appWindow.enableDebugOutput) {
            console.log("Putting Data to DB (NavigationBar): JSON.stringify(myData): " + JSON.stringify(
                            myData))
        }
        luna.call("luna://com.palm.db/put", JSON.stringify({
                                                               objects: [myData]
                                                           }),
                  __handlePutDBSuccess, __handlePutDBError)
    }

    function __handlePutDBError(message) {
        console.log("Could not put DB : " + message)
    }

    function __handlePutDBSuccess(message) {
        if (appWindow.enableDebugOutput) {
            console.log("Put DB: " + JSON.stringify(message.payload))
        }
    }

    function __getDefaultSearch() {
        if (appWindow.enableDebugOutput) {
            console.log("Getting default search")
        }
        luna.call("luna://com.palm.universalsearch/getAllSearchPreference",
                  JSON.stringify("{}"), __handleGetDefaultSearchSuccess,
                  __handleGetDefaultSearchError)
    }

    function __handleGetDefaultSearchSuccess(message) {
        if (appWindow.enableDebugOutput) {
            console.log("Got default search successfully")
        }
        var defbrows = JSON.parse(message.payload)
        defaultSearch = defbrows.SearchPreference.defaultSearchEngine
        luna.call("luna://com.palm.universalsearch/getUniversalSearchList",
                  JSON.stringify("{}"), __handleGetSearchSuccess,
                  __handleGetDefaultSearchError)
    }

    function __handleGetSearchSuccess(message) {
        if (appWindow.enableDebugOutput) {
            console.log("Got search items successfully")
        }

        var defbrows2 = JSON.parse(message.payload)

        //Maybe not very pretty, but it works
        for (var i = 0, s; s = defbrows2.UniversalSearchList[i]; i++) {
            if (s.id === defaultSearch) {
                defaultSearchURL = s.url
                defaultSearchIcon = s.iconFilePath
                defaultSearchDisplayName = s.displayName
            } else {
                console.log("Cannot find information for default search engine")
            }
        }
    }

    function __handleGetDefaultSearchError(message) {
        console.log("Failed to get default search engine: " + JSON.stringify(
                        message.payload))
    }

    BorderImage {
        source: "images/toolbar.png"
        height: parent.height
        border.left: 20; border.right: 20
        width: parent.width // + 40
    }

    RowLayout {
        anchors.fill: parent

        Image {
            id: backImage
            source: "images/menu-icon-back.png"
            anchors.verticalCenter: parent.verticalCenter
            Layout.leftMargin: Units.gu(1)
            Layout.preferredWidth: Units.gu(4)
            Layout.preferredHeight: Units.gu(4)

            fillMode: Image.PreserveAspectCrop
            verticalAlignment: backImageMouseArea.pressed ? Image.AlignBottom : Image.AlignTop
            opacity: backImageMouseArea.enabled ? 1.0 : 0.5

            MouseArea {
                id: backImageMouseArea
                anchors.fill: parent
                enabled: webView.canGoBack

                onClicked: {
                    if (webView.canGoBack) {
                        webView.goBack()
                    } else {
                        console.log("No history available")
                    }
                }
            }
        }

        Image {
            id: forwardImage
            source: "images/menu-icon-forward.png"
            Layout.preferredWidth: Units.gu(4)
            Layout.preferredHeight: Units.gu(4)
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectCrop
            verticalAlignment: forwardImageMouseArea.pressed ? Image.AlignBottom : Image.AlignTop
            opacity: forwardImageMouseArea.enabled ? 1.0 : 0.5

            MouseArea {
                id: forwardImageMouseArea
                anchors.fill: parent
                enabled: webView.canGoForward

                onClicked: {
                    if (webView.canGoForward) {
                        webView.goForward()
                    } else {
                        forwardImage.opacity = 0.5
                    }
                }
            }
        }

        Image {
            id: secureSite
            source: "images/secure-lock.png"
            Layout.preferredWidth: Units.gu(3.75)
            Layout.preferredHeight: Units.gu(3.75)
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.9
            visible: navigationBar.isSecureSite
        }

        AddressBarItem {
            id: addressBarItem
            Layout.fillWidth: true
            anchors.verticalCenter: parent.verticalCenter
            Layout.preferredHeight: parent.height - Units.gu(1.6)
            Layout.leftMargin: Units.gu(0.8)
            Layout.rightMargin: Units.gu(0.8)
        }

        Image {
            id: shareImage
            Layout.preferredWidth: Units.gu(4)
            Layout.preferredHeight: Units.gu(4)
            anchors.verticalCenter: parent.verticalCenter
            source: "images/menu-icon-share.png"
            fillMode: Image.PreserveAspectCrop
            verticalAlignment: shareImageMouseArea.pressed ? Image.AlignBottom : Image.AlignTop
            opacity: webViewItem.loadProgress === 100 ? 1.0 : 0.5;

            MouseArea {
                id: shareImageMouseArea
                anchors.fill: parent
                enabled: webViewItem.loadProgress === 100

                onClicked: {
                    toggleShareOptionsList();
                }
            }
        }

        Image {
            id: newCardImage
            Layout.preferredWidth: Units.gu(4)
            Layout.preferredHeight: Units.gu(4)
            anchors.verticalCenter: parent.verticalCenter
            source: "images/menu-icon-newcard.png"
            fillMode: Image.PreserveAspectCrop
            verticalAlignment: newCardImageMouseArea.pressed ? Image.AlignBottom : Image.AlignTop
            opacity: 1

            MouseArea {
                id: newCardImageMouseArea
                anchors.fill: parent

                onPressed: {
                    if (appWindow.enableDebugOutput) {
                        console.log("New Card Pressed")
                    }
                    newCardImage.verticalAlignment = Image.AlignBottom
                    navigationBar.__launchApplication("org.webosports.app.browser",
                                                      "{}")
                }
                onCanceled: {
                    if (appWindow.enableDebugOutput) {
                        console.log("New Card Released")
                    }
                    newCardImage.verticalAlignment = Image.AlignTop
                }
                onReleased: {
                    if (appWindow.enableDebugOutput) {
                        console.log("New Card Released")
                    }
                    newCardImage.verticalAlignment = Image.AlignTop
                }
            }
        }

        Image {
            id: bookmarkImage
            Layout.preferredWidth: Units.gu(4)
            Layout.preferredHeight: Units.gu(4)
            anchors.verticalCenter: parent.verticalCenter
            source: "images/menu-icon-bookmark.png"
            clip: true
            fillMode: Image.PreserveAspectCrop
            verticalAlignment: bookmarkImageMouseArea.pressed ? Image.AlignBottom : Image.AlignTop
            opacity: 1

            MouseArea {
                id: bookmarkImageMouseArea
                anchors.fill: parent

                onClicked: {
                    navigationBar.__queryDB(
                                "find",
                                '{"query":{"from":"com.palm.browserbookmarks:1", "limit":32}}')

                    navigationBar.__queryDB(
                                "find",
                                '{"query":{"from":"com.palm.browserhistory:1", "limit":50, "orderBy":"date"}}')

                    Qt.inputMethod.hide()
                    toggleHistoryPanel();
                }
            }
        }

        Image {
            id: vkbImage
            Layout.preferredWidth: Units.gu(4)
            Layout.preferredHeight: Units.gu(4)
            anchors.verticalCenter: parent.verticalCenter
            source: "images/icon-hide-keyboard.png"
            clip: true
            fillMode: Image.PreserveAspectCrop
            visible: AppTweaks.toggleVKBTweakValue
            opacity: 1

            MouseArea {
                anchors.fill: parent

                onPressed: {
                    if (Qt.inputMethod.visible) {
                        Qt.inputMethod.hide()
                    } else {
                        addressBar.focus = true
                        Qt.inputMethod.show()
                    }
                }
            }
        }
    }

    DialogHelper {
        id: navigationBarDlgHelper
    }

    SearchSuggestions {
        id: searchSuggestions
        anchors.left: parent.left
        anchors.top: parent.bottom
        anchors.leftMargin: Screen.width < 900 ? 0 : isSecureSite ? Units.gu(
                                                                        13.75) : Units.gu(
                                                                        10)
        width: Screen.width < 900 ? Screen.width : addressBarItem.width

        searchString: addressBarItem.addressBarText
        optSearchText: defaultSearchDisplayName
        defaultSearchIcon: navigationBar.defaultSearchIcon

        onSuggestionsCountChanged: {
            if(count===0) searchSuggestions.hide();
            else navigationBarDlgHelper.showDialog(searchSuggestions, false);
        }
        onRequestUrl: {
            webView.url = url;
            addressBarItem.addressBarText = url;
        }
    }
}

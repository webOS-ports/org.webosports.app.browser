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
import "Utils"

Rectangle {
    id: navigationBar

    property bool alwaysShowProgressBar: false
    property bool showVKBButton: false
    property string searchProviderIcon: ""
    property Item webView: null
    property string defaultSearch: ""
    property string defaultSearchURL: ""
    property string defaultSearchIcon: "images/list-icon-google.png"
    property string defaultSearchDisplayName: "Google"
    property bool isSecureSite: false
    property int addressBarWidth: 0
    property var searchResultsBookmarks
    property var searchResultsHistory

    property bool initialSelection: true
    width: parent.width
    height: Units.gu(5.2)
    color: "#343434"

    Component.onCompleted: navigationBar.__getDefaultSearch()

    SearchSuggestions {
        id: searchSuggestions
    }

    Image {
        id: topMarker
        source: "images/topmarker.png"
        visible: false
        z: 500
    }

    Image {
        id: bottomMarker
        source: "images/bottommarker.png"
        visible: false
        z: 500
    }

    Rectangle {
        id: cutCopyPasteRectangle
        width: Units.gu(10)
        color: "transparent"
        anchors.top: navigationBar.bottom
        x: 100
        visible: false

        Image {
            id: cutCopyPasteRectLeft
            source: "images/ate-left.png"
            anchors.right: cutCopyPasteRectMiddleLeft.left
        }
        Image {
            id: cutCopyPasteRectMiddleLeft
            source: "images/ate-middle.png"
            anchors.right: cutCopyPasteRectMiddleMiddle.left
            width: (cutCopyPasteTextCut.width + cutCopyPasteTextCopy.width
                    + cutCopyPasteTextPaste.width) / 2
            fillMode: Image.Stretch
        }

        Image {
            id: cutCopyPasteRectMiddleMiddle
            source: "images/ate-arrow-up.png"
            anchors.left: cutCopyPasteRectMiddleLeft.right
            anchors.bottom: cutCopyPasteRectMiddleLeft.bottom
            anchors.bottomMargin: 7
            width: 33
        }

        Image {
            id: cutCopyPasteRectMiddleRight
            source: "images/ate-middle.png"
            anchors.left: cutCopyPasteRectMiddleMiddle.right
            width: (cutCopyPasteTextCut.width + cutCopyPasteTextCopy.width
                    + cutCopyPasteTextPaste.width) / 2
            fillMode: Image.Stretch
        }

        Image {
            id: cutCopyPasteRectRight
            source: "images/ate-right.png"
            anchors.left: cutCopyPasteRectMiddleRight.right
        }

        Text {
            id: cutCopyPasteTextCut
            text: "Cut"
            anchors.left: cutCopyPasteRectMiddleLeft.left
            anchors.verticalCenter: cutCopyPasteRectMiddleLeft.verticalCenter
            anchors.verticalCenterOffset: -6
            anchors.leftMargin: Units.gu(1)
            font.family: "Prelude"
            font.weight: Font.DemiBold
            font.pixelSize: FontUtils.sizeToPixels("medium")
            color: "#E5E5E5"
            MouseArea {
                anchors.fill: parent

                onClicked: {
                    addressBar.cut()
                    addressBar.state = "selection"
                    cutCopyPasteRectangle.visible = false
                    cutCopyRectangle.visible = false
                    pasteRectangle.visible = false
                    selectSelectAllRectangle.visible = false
                    bottomMarker.visible = false
                    topMarker.visible = false
                }
            }
        }

        Image {
            id: cutCopyPasteDividerImageLeft
            source: "images/ate-divider.png"
            anchors.verticalCenter: cutCopyPasteTextCut.verticalCenter
            anchors.left: cutCopyPasteTextCut.right
            anchors.leftMargin: Units.gu(0.75)
        }

        Text {
            id: cutCopyPasteTextCopy
            text: "Copy"
            anchors.left: cutCopyPasteTextCut.right
            anchors.leftMargin: Units.gu(2)
            anchors.verticalCenter: cutCopyPasteRectMiddleLeft.verticalCenter
            anchors.verticalCenterOffset: -6
            font.family: "Prelude"
            font.pixelSize: FontUtils.sizeToPixels("medium")
            font.weight: Font.DemiBold
            color: "#E5E5E5"
            MouseArea {
                anchors.fill: parent

                onClicked: {
                    addressBar.copy()
                    cutCopyPasteRectangle.visible = false
                    cutCopyRectangle.visible = false
                    pasteRectangle.visible = false
                    selectSelectAllRectangle.visible = false
                    addressBar.state = "selection"
                    bottomMarker.visible = true
                    topMarker.visible = true
                }
            }
        }

        Image {
            id: cutCopyPasteDividerImageRight
            source: "images/ate-divider.png"
            anchors.verticalCenter: cutCopyPasteTextCopy.verticalCenter
            anchors.left: cutCopyPasteTextCopy.right
            anchors.leftMargin: Units.gu(0.75)
        }

        Text {
            id: cutCopyPasteTextPaste
            text: "Paste"
            anchors.leftMargin: Units.gu(2)
            anchors.left: cutCopyPasteTextCopy.right
            anchors.verticalCenter: cutCopyPasteRectMiddleRight.verticalCenter
            anchors.verticalCenterOffset: -6
            font.family: "Prelude"
            font.pixelSize: FontUtils.sizeToPixels("medium")
            font.weight: Font.DemiBold
            color: "#E5E5E5"
            MouseArea {
                anchors.fill: parent

                onClicked: {
                    addressBar.paste()
                    cutCopyPasteRectangle.visible = false
                    cutCopyRectangle.visible = false
                    pasteRectangle.visible = false
                    selectSelectAllRectangle.visible = false
                    addressBar.state = ""
                    bottomMarker.visible = false
                    topMarker.visible = false
                }
            }
        }
        Component.onCompleted: {
            cutCopyPasteRectMiddleLeft.width
                    = (cutCopyPasteTextCut.width + cutCopyPasteTextCopy.width
                       + cutCopyPasteTextPaste.width + Units.gu(4)) / 2
            cutCopyPasteRectMiddleRight.width
                    = (cutCopyPasteTextCut.width + cutCopyPasteTextCopy.width
                       + cutCopyPasteTextPaste.width + Units.gu(4)) / 2
        }
    }

    Rectangle {
        id: cutCopyRectangle
        width: Units.gu(10)
        color: "transparent"
        anchors.top: navigationBar.bottom
        visible: false
        Image {
            id: cutCopyRectLeft
            source: "images/ate-left.png"
            anchors.right: cutCopyRectMiddleLeft.left
        }
        Image {
            id: cutCopyRectMiddleLeft
            source: "images/ate-middle.png"
            anchors.right: cutCopyRectArrowUp.left
            width: cutCopyTextCut.width
            fillMode: Image.Stretch

            Text {
                id: cutCopyTextCut
                text: "Cut"
                anchors.verticalCenter: cutCopyRectMiddleLeft.verticalCenter
                anchors.verticalCenterOffset: -6
                font.family: "Prelude"
                font.weight: Font.DemiBold
                font.pixelSize: FontUtils.sizeToPixels("medium")
                color: "#E5E5E5"
                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        addressBar.cut()
                        addressBar.state = "selection"
                        cutCopyRectangle.visible = false
                        cutCopyPasteRectangle.visible = false
                        pasteRectangle.visible = false
                        selectSelectAllRectangle.visible = false
                        bottomMarker.visible = false
                        topMarker.visible = false
                    }
                }
            }
        }

        Image {
            id: cutCopyRectArrowUp
            source: "images/ate-arrow-up.png"
            anchors.bottom: cutCopyRectMiddleLeft.bottom
            anchors.bottomMargin: 7
            anchors.horizontalCenter: cutCopyRectangle.horizontalCenter
        }

        Image {
            id: cutCopyDividerImageCenter
            source: "images/ate-divider.png"
            anchors.verticalCenter: cutCopyRectArrowUp.verticalCenter
            anchors.horizontalCenter: cutCopyRectArrowUp.horizontalCenter
        }
        Image {
            id: cutCopyRectMiddleRight
            source: "images/ate-middle.png"
            anchors.left: cutCopyRectArrowUp.right
            width: cutCopyTextCopy.width
            fillMode: Image.Stretch

            Text {
                id: cutCopyTextCopy
                text: "Copy"
                anchors.left: cutCopyRectMiddleRight.left
                anchors.verticalCenter: cutCopyRectMiddleRight.verticalCenter
                anchors.verticalCenterOffset: -6
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("medium")
                font.weight: Font.DemiBold
                color: "#E5E5E5"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        addressBar.copy()
                        cutCopyRectangle.visible = false
                        cutCopyPasteRectangle.visible = false
                        pasteRectangle.visible = false
                        selectSelectAllRectangle.visible = false
                        addressBar.state = "selection"
                        bottomMarker.visible = true
                        topMarker.visible = true

                    }
                }
            }
        }
        Image {
            id: cutCopyRectRight
            source: "images/ate-right.png"
            anchors.left: cutCopyRectMiddleRight.right
        }
    }

    Rectangle {
        id: selectSelectAllRectangle
        width: Units.gu(10)
        color: "transparent"
        anchors.top: navigationBar.bottom
        visible: false
        Image {
            id: selectSelectAllRectLeft
            source: "images/ate-left.png"
            anchors.right: selectSelectAllRectMiddleLeft.left
        }
        Image {
            id: selectSelectAllRectMiddleLeft
            source: "images/ate-middle.png"
            anchors.right: selectSelectAllRectArrowUp.left
            width: selectSelectAllTextSelect.width
            fillMode: Image.Stretch

            Text {
                id: selectSelectAllTextSelect
                text: "Select"
                anchors.verticalCenter: selectSelectAllRectMiddleLeft.verticalCenter
                anchors.verticalCenterOffset: -6
                font.family: "Prelude"
                font.weight: Font.DemiBold
                font.pixelSize: FontUtils.sizeToPixels("medium")
                color: "#E5E5E5"
                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        addressBar.selectWord()
                        addressBar.state = "selection"
                        selectSelectAllRectangle.visible = false
                        cutCopyPasteRectangle.visible = false
                        cutCopyRectangle.visible = false
                        pasteRectangle.visible = false
                        topMarker.x = addressBar.x + addressBar.positionToRectangle(
                                    addressBar.selectionStart).x - (topMarker.width / 2)
                        topMarker.y = addressBar.y + addressBar.positionToRectangle(
                                    addressBar.selectionStart).y - topMarker.height
                        bottomMarker.x = addressBar.x + addressBar.positionToRectangle(
                                    addressBar.selectionEnd).x - (bottomMarker.width / 2)
                        bottomMarker.y = addressBar.positionToRectangle(
                                    addressBar.selectionEnd).y + addressBar.positionToRectangle(
                                    addressBar.selectionEnd).height + (bottomMarker.height / 2)
                        bottomMarker.visible = true
                        topMarker.visible = true
                    }
                }
            }
        }

        Image {
            id: selectSelectAllRectArrowUp
            source: "images/ate-arrow-up.png"
            anchors.bottom: selectSelectAllRectMiddleLeft.bottom
            anchors.bottomMargin: 7
            anchors.horizontalCenter: selectSelectAllRectangle.horizontalCenter
        }

        Image {
            id: selectSelectAllDividerImageCenter
            source: "images/ate-divider.png"
            anchors.verticalCenter: selectSelectAllRectArrowUp.verticalCenter
            anchors.horizontalCenter: selectSelectAllRectArrowUp.horizontalCenter
        }
        Image {
            id: selectSelectAllRectMiddleRight
            source: "images/ate-middle.png"
            anchors.left: selectSelectAllRectArrowUp.right
            width: selectSelectAllTextSelectAll.width
            fillMode: Image.Stretch

            Text {
                id: selectSelectAllTextSelectAll
                text: "Select All"
                anchors.left: selectSelectAllRectMiddleRight.left
                anchors.verticalCenter: selectSelectAllRectMiddleRight.verticalCenter
                anchors.verticalCenterOffset: -6
                font.family: "Prelude"
                font.pixelSize: FontUtils.sizeToPixels("medium")
                font.weight: Font.DemiBold
                color: "#E5E5E5"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        addressBar.selectAll()
                        selectSelectAllRectangle.visible = false
                        cutCopyPasteRectangle.visible = false
                        cutCopyRectangle.visible = false
                        pasteRectangle.visible = false
                        addressBar.state = "selection"
                        bottomMarker.visible = true
                        topMarker.visible = true
                        topMarker.x = addressBar.x + addressBar.positionToRectangle(
                                    addressBar.selectionStart).x - (topMarker.width / 2)
                        topMarker.y = addressBar.y + addressBar.positionToRectangle(
                                    addressBar.selectionStart).y - topMarker.height
                        bottomMarker.x = addressBar.x + addressBar.positionToRectangle(
                                    addressBar.selectionEnd).x - (bottomMarker.width / 2)
                        bottomMarker.y = addressBar.positionToRectangle(
                                    addressBar.selectionEnd).y + addressBar.positionToRectangle(
                                    addressBar.selectionEnd).height + (bottomMarker.height / 2)

                    }
                }
            }
        }
        Image {
            id: selectSelectAllRectRight
            source: "images/ate-right.png"
            anchors.left: selectSelectAllRectMiddleRight.right
        }
    }



    Rectangle {
        id: pasteRectangle
        width: Units.gu(10)
        color: "transparent"
        anchors.top: navigationBar.bottom
        visible: false

        Text {
            id: pastePasteText
            text: "Paste"
            anchors.verticalCenter: pasteRectLeft.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: -6
            font.family: "Prelude"
            font.weight: Font.DemiBold
            font.pixelSize: FontUtils.sizeToPixels("medium")
            color: "#E5E5E5"
            z: 10
            MouseArea {
                anchors.fill: parent

                onClicked: {
                    addressBar.paste()
                    addressBar.state = ""
                    pasteRectangle.visible = false
                    cutCopyPasteRectangle.visible = false
                    cutCopyRectangle.visible = false
                    selectSelectAllRectangle.visible = false
                    bottomMarker.visible = false
                    topMarker.visible = false
                }
            }
        }

        Image {
            id: pasteRectLeft
            source: "images/ate-left.png"
            anchors.right: pasteRectMiddleLeft.left
        }
        Image {
            id: pasteRectMiddleLeft
            source: "images/ate-middle.png"
            anchors.right: pasteRectArrowUp.left
            width: 8
        }

        Image {
            id: pasteRectArrowUp
            source: "images/ate-arrow-up.png"
            anchors.bottom: pasteRectMiddleLeft.bottom
            anchors.bottomMargin: 7
            anchors.horizontalCenter: pasteRectangle.horizontalCenter
        }

        Image {
            id: pasteRectMiddleRight
            source: "images/ate-middle.png"
            anchors.left: pasteRectArrowUp.right
            width: 8
        }

        Image {
            id: pasteRectRight
            source: "images/ate-right.png"
            anchors.left: pasteRectMiddleRight.right
        }
        Component.onCompleted:
        {
            pasteRectMiddleLeft.width = pastePasteText.width / 2
            pasteRectMiddleRight.width = pastePasteText.width / 2
        }
    }

    Tweak {
        id: progressBarTweak
        owner: "org.webosports.app.browser"
        key: "alwaysShowProgressBarKey"
        defaultValue: "false"
        onValueChanged: updateProgressBar()

        function updateProgressBar() {

            if (progressBarTweak.value === true) {
                alwaysShowProgressBar = true
            } else {
                alwaysShowProgressBar = false
            }
            if (root.enableDebugOutput) {
                console.log("alwaysShowProgressBar: " + alwaysShowProgressBar)
            }
        }
    }

    Tweak {
        id: toggleVKBTweak
        owner: "org.webosports.app.browser"
        key: "toggleVKBKey"
        defaultValue: "false"
        onValueChanged: updateToggleVKBButton()

        function updateToggleVKBButton() {

            if (toggleVKBTweak.value === true) {
                showVKBButton = true
            } else {
                showVKBButton = false
            }
            if (root.enableDebugOutput) {
                console.log("showVKButton: " + showVKBButton)
            }
        }
    }

    /////// private //////
    LunaService {
        id: luna
        name: "org.webosports.app.browser"
    }

    function setFocus(focusState) {
        if (root.enableDebugOutput) {
            console.log("setFocus called with" + focusState)
        }
        addressBar.focus = focusState
    }

    function __launchApplication(id, params) {
        if (root.enableDebugOutput) {
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

    function __queryDB(action, params) {
        if (root.enableDebugOutput) {
            console.log("Querying DB with action: " + action + " and params: " + params)
        }
        luna.call("luna://com.palm.db/" + action, params,
                  __handleQueryDBSuccess, __handleQueryDBError)
    }

    function __handleQueryDBError(message) {
        console.log("Could not query DB : " + message)
    }

    function __handleQueryDBSuccess(message) {
        if (root.enableDebugOutput) {
            console.log("Queried DB : " + JSON.stringify(message.payload))
        }
        searchResultsBookmarks = JSON.parse(message.payload)
        navigationBar.__queryHDB(
                    "search",
                    '{"query":{"from":"com.palm.browserhistory:1", "where":[{"prop":"searchText", "op":"?", "val":'
                    + "\"" + addressBar.text + "\""
                    + ', "collate":"primary"}], "orderBy": "_rev", "desc": true}}')
    }

    function __queryHDB(action, params) {
        if (root.enableDebugOutput) {
            console.log("Querying History DB with action: " + action + " and params: " + params)
        }
        luna.call("luna://com.palm.db/" + action, params,
                  __handleQueryHDBSuccess, __handleQueryHDBError)
    }

    function __handleQueryHDBError(message) {
        console.log("Could not query History DB : " + message)
    }

    function __handleQueryHDBSuccess(message) {
        if (root.enableDebugOutput) {
            console.log("Queried History DB : " + JSON.stringify(
                            message.payload))
        }

        searchResultsHistory = JSON.parse(message.payload)

        //We need to put the icon for each of the types (bookmarks/history) so we put them in a new combined array
        var searchResults = []

        for (var j = 0, t; t = searchResultsBookmarks.results[j]; j++) {
            searchResults.push({
                                   url: t.url,
                                   title: t.title,
                                   icon: "images/header-icon-bookmarks.png"
                               })
        }
        if (searchResultsHistory.results.length <= 32) {
            for (var i = 0, s; s = searchResultsHistory.results[i]; i++) {
                searchResults.push({
                                       url: s.url,
                                       title: s.title,
                                       icon: "images/header-icon-history.png"
                                   })
            }
        }

        //Stringify them so we can use it in the JSONList
        searchSuggestions.searchResultsAll = JSON.stringify(searchResults)
        return searchSuggestions.searchResultsAll
    }

    function __queryPutDB(myData) {
        if (root.enableDebugOutput) {
            console.log("Putting Data to DB: JSON.stringify(myData): " + JSON.stringify(
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
        if (root.enableDebugOutput) {
            console.log("Put DB: " + JSON.stringify(message.payload))
        }
    }

    function __getDefaultSearch() {
        if (root.enableDebugOutput) {
            console.log("Getting default search")
        }
        luna.call("luna://com.palm.universalsearch/getAllSearchPreference",
                  JSON.stringify("{}"), __handleGetDefaultSearchSuccess,
                  __handleGetDefaultSearchError)
    }

    function __handleGetDefaultSearchSuccess(message) {
        if (root.enableDebugOutput) {
            console.log("Got default search successfully")
        }
        var defbrows = JSON.parse(message.payload)
        defaultSearch = defbrows.SearchPreference.defaultSearchEngine
        luna.call("luna://com.palm.universalsearch/getUniversalSearchList",
                  JSON.stringify("{}"), __handleGetSearchSuccess,
                  __handleGetDefaultSearchError)
    }

    function __handleGetSearchSuccess(message) {
        if (root.enableDebugOutput) {
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

    Image {
        id: navigationBarBG
        source: "images/toolbar.png"
        height: parent.height
        //This is a bit hacky, but QML isn't as flexible as CSS
        x: -20
        width: parent.width + 40
        fillMode: Image.Stretch
    }

    Image {
        id: backImage
        anchors.verticalCenter: navigationBar.verticalCenter
        source: "images/menu-icon-back.png"
        x: Units.gu(1)
        height: Units.gu(4)
        width: Units.gu(4)
        clip: true
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: Image.AlignTop
        opacity: historyAvailable ? 1.0 : 0.5

        MouseArea {
            anchors.fill: parent

            onPressed: {
                if (shareOptionsList.visible) {
                    shareOptionsList.visible = false
                }

                if (webView.canGoBack) {
                    backImage.verticalAlignment = Image.AlignBottom
                    webView.goBack()
                    forwardAvailable = true
                } else {
                    console.log("No history available")
                }
            }

            onReleased: {
                backImage.verticalAlignment = Image.AlignTop
            }
        }
    }

    Image {
        id: forwardImage
        anchors.left: backImage.right
        anchors.verticalCenter: navigationBar.verticalCenter
        source: "images/menu-icon-forward.png"
        height: Units.gu(4)
        width: Units.gu(4)
        //webOS sprites are tricky in QML, but with below we can use the parts we want.
        clip: true
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: Image.AlignTop
        opacity: webView.canGoForward ? 1.0 : 0.5

        MouseArea {
            anchors.fill: parent

            onPressed: {
                if (shareOptionsList.visible) {
                    shareOptionsList.visible = false
                }

                if (webView.canGoForward) {
                    forwardImage.verticalAlignment = Image.AlignBottom
                    webView.goForward()
                } else {
                    forwardImage.opacity = 0.5
                }
            }
            onReleased: {
                forwardImage.verticalAlignment = Image.AlignTop
                if (webView.canGoForward) {
                    forwardImage.opacity = 1
                } else {
                    forwardImage.opacity = 0.5
                }
            }
        }
    }

    Image {
        id: secureSite
        anchors.verticalCenter: forwardImage.verticalCenter
        anchors.left: forwardImage.right
        source: "images/secure-lock.png"
        height: Units.gu(3.75)
        width: Units.gu(0)
        opacity: 0.9
        visible: false
    }

    TextInput {
        id: addressBar
        anchors.leftMargin: Units.gu(1)
        anchors.left: secureSite.right
        anchors.verticalCenter: navigationBar.verticalCenter
        width: navigationBar.width - forwardImage.width - backImage.width - shareImage.width
               - newCardImage.width - bookmarkImage.width - vkbImage.width - Units.gu(
                   2.5)
        clip: true
        height: Units.gu(3.5)
        font.family: "Prelude"
        font.pixelSize: FontUtils.sizeToPixels("medium")
        //Force the URL keyboard layout
        inputMethodHints: Qt.ImhUrlCharactersOnly
        color: root.privateByDefault ? "#2E8CF7" : "#E5E5E5"
        selectedTextColor: "#000000"
        selectionColor: "#ADAD15"
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignLeft
        focus: true
        anchors.margins: Units.gu(1)
        text: ""

        onAccepted: updateURL()
        onFocusChanged: {
            searchSuggestions.visible = false
        }

        onActiveFocusChanged: {
            Qt.inputMethod.show()
        }

        onContentSizeChanged: {
            //We need to hide any copy/paste selection bits when we change length
            cutCopyPasteRectangle.visible = false
            pasteRectangle.visible = false
            selectSelectAllRectangle.visible = false
            cutCopyRectangle.visible = false
            bottomMarker.visible = false
            topMarker.visible = false

            addressBarWidth = addressBar.width
            //We need a different query in case the lenght is 0
            if (addressBar.text.length === 0) {
                navigationBar.__queryDB(
                            "find",
                            '{"query":{"from":"com.palm.browserbookmarks:1"}}')
            } else {
                navigationBar.__queryDB(
                            "search",
                            '{"query":{"from":"com.palm.browserbookmarks:1", "where":[{"prop":"searchText", "op":"?", "val":'
                            + "\"" + addressBar.text + "\""
                            + ', "collate":"primary"}], "orderBy": "_rev", "desc": true}}')
            }
            searchSuggestions.optSearchText = defaultSearchDisplayName
            searchSuggestions.defaultSearchIcon = defaultSearchIcon
            searchSuggestions.height = (searchSuggestions.urlModelCount + 1) * Units.gu(
                        6)
            searchSuggestions.suggestionListHeight = searchSuggestions.urlModelCount * Units.gu(
                        6)
            if (addressBar.text.length === 0 || addressBar.text.substring(
                        0,
                        4) === "http" || addressBar.text.substring(0,
                                                                   3) === "ftp"
                    || addressBar.text.substring(0, 4) === "data") {
                searchSuggestions.visible = false
            } else {
                searchSuggestions.visible = true
            }
        }

        Rectangle {
            id: addressBarRect

            height: parent.height
            width: parent.width
            color: "transparent"

            //This one is nasty, but to due QML limitations need to use 3 images for this.
            Image {
                id: leftAddressBar
                height: parent.height
                width: Units.gu(2)
                anchors.left: addressBarRect.left

                source: "images/input-tool-left.png"
            }

            Image {
                id: centerAddressBar
                height: parent.height
                width: parent.width - leftAddressBar.width - rightAddressBar.width
                anchors.left: leftAddressBar.right
                fillMode: Image.Stretch
                source: "images/input-tool-center.png"
            }

            Image {
                id: rightAddressBar
                height: parent.height
                width: Units.gu(2)
                anchors.left: centerAddressBar.right
                source: "images/input-tool-right.png"
            }
        }

        Image {
            id: faviconImage
            anchors.right: addressBar.right
            source: webView.icon
        }
        Image {
            id: loadingIndicator

            anchors.right: addressBar.right
            anchors.verticalCenter: addressBar.verticalCenter
            height: Units.gu(3.75)
            width: Units.gu(3.75)
            clip: true
            fillMode: Image.PreserveAspectCrop
            verticalAlignment: Image.AlignTop
            source: "images/menu-icon-refresh.png"

            //Handle stop/reload
            MouseArea {
                anchors.fill: loadingIndicator

                onPressed: {
                    if (shareOptionsList.visible) {
                        shareOptionsList.visible = false
                    }
                    if (webView.canGoBack) {
                        backImage.opacity = 1
                    }
                    if (webView.canGoForward) {
                        forwardImage.opacity = 1
                    }

                    //TODO: Work out a more proper way of dealing with this. It works currently but it's not pretty
                    var myString = "'" + loadingIndicator.source
                    var mySplit = myString.split("/")
                    if (mySplit[mySplit.length - 1] === 'menu-icon-refresh.png') {

                        if (addressBar.text !== "") {
                            progressBar.height = Units.gu(1 / 2)
                            progressBar.value = 0
                        }
                        webView.reload
                        loadingIndicator.source = "images/menu-icon-stop.png"
                    } else {
                        if (addressBar.selectedText !== "") {
                            addressBar.deselect
                            addressBar.focus = true
                            addressBar.text = ""
                            Qt.inputMethod.show()
                        } else {
                            webView.stop
                            loadingIndicator.source = "images/menu-icon-refresh.png"
                            if (!alwaysShowProgressBar) {
                                progressBar.height = 0
                            }
                            progressBar.value = 0
                        }
                    }
                }
            }
        }

        Timer {
            id: urlTimer
            running: webView.loadProgress === 100 && addressBar.text !== ""
            repeat: true
            interval: 500
            onTriggered: {

                if (!webView.loading) {
                    if (!alwaysShowProgressBar) {
                        progressBar.height = 0
                    }
                }

                if (addressBar.selectedText === "") {
                    loadingIndicator.source = "images/menu-icon-refresh.png"
                    urlTimer.stop
                }
                if (webView.canGoBack) {
                    backImage.opacity = 1.0
                    shareImage.opacity = 1.0
                } else {
                    backImage.opacity = 0.5
                }

                if (webView.canGoForward) {
                    forwardImage.opacity = 1.0
                } else {
                    forwardImage.opacity = 0.5
                }
            }
        }

        Timer {
            id: urlTimer2
            running: webView.loadProgress === 100 && addressBar.text !== ""
            repeat: false
            interval: 100
            onTriggered: {

                if (!webView.loading) {
                    progressBar.progressBarColor = "green"
                }

                if (webView.canGoBack) {
                    backImage.opacity = 1.0
                    shareImage.opacity = 1.0
                } else {
                    backImage.opacity = 0.5
                }

                if (webView.canGoForward) {
                    forwardImage.opacity = 1.0
                } else {
                    forwardImage.opacity = 0.5
                }

            }
        }

        Timer {
            id: urlTimer3
            running: webView.loading
            repeat: false
            interval: 100
            onTriggered: {
                addressBar.text = webViewItem.url
            }
        }

        MouseArea {
            id: selectText
            width: parent.width - loadingIndicator.width
            height: parent.height
            anchors.left: parent.left

            onClicked: {
                if (root.enableDebugOutput) {
                    console.log("onClicked addressBar.selectedText: "+addressBar.selectedText+ " addressBar.state: "+addressBar.state+ " initial selection: "+initialSelection)
                }
                if (shareOptionsList.visible) {
                    shareOptionsList.visible = false
                }
                if ((!addressBar.selectedText && initialSelection) || addressBar.state === "") {
                    initialSelection = false
                    addressBar.focus = true
                    addressBar.state = "selection"
                    addressBar.selectAll()

                } else if (topMarker.visible && bottomMarker.visible && addressBar.selectedText && addressBar.state === "selection" && !initialSelection){
                    topMarker.visible = false
                    bottomMarker.visible = false
                    cutCopyPasteRectangle.visible = false
                    pasteRectangle.visible = false
                    selectSelectAllRectangle.visible = false
                    cutCopyRectangle.visible = false
                    addressBar.cursorPosition = addressBar.positionAt(mouse.x)
                } else if(!addressBar.selectedText && !initialSelection && addressBar.state==="selection"){
                    cutCopyPasteRectangle.visible = false
                    pasteRectangle.visible = false
                    selectSelectAllRectangle.visible = false
                    cutCopyRectangle.visible = false
                    bottomMarker.visible = false
                    topMarker.visible = false
                    addressBar.focus = true
                    initialSelection = true
                    addressBar.cursorPosition = addressBar.positionAt(mouse.x)
                } else if ((addressBar.selectedText && !initialSelection) || (addressBar.selectedText && initialSelection && addressBar.state === "selection")) {
                    topMarker.x = addressBar.x + addressBar.positionToRectangle(
                                addressBar.selectionStart).x - (topMarker.width / 2)
                    topMarker.y = addressBar.y + addressBar.positionToRectangle(
                                addressBar.selectionStart).y - topMarker.height
                    topMarker.visible = true
                    bottomMarker.x = addressBar.x + addressBar.positionToRectangle(
                                addressBar.selectionEnd).x - (bottomMarker.width / 2)
                    bottomMarker.y = addressBar.positionToRectangle(
                                addressBar.selectionEnd).y + addressBar.positionToRectangle(
                                addressBar.selectionEnd).height + (bottomMarker.height / 2)
                    bottomMarker.visible = true
                    cutCopyPasteRectangle.visible = false
                    pasteRectangle.visible = false
                    selectSelectAllRectangle.visible = false
                    cutCopyRectangle.visible = true
                    cutCopyRectangle.x = ((topMarker.x + bottomMarker.x) / 2)
                            - (cutCopyRectangle.width / 2)
                } else {
                    topMarker.visible = false
                    bottomMarker.visible = false
                    addressBar.cursorPosition = addressBar.positionAt(mouse.x)
                }
            }

            onPressAndHold: {
                if (root.enableDebugOutput) {
                    console.log("onPressAndHold addressBar.selectedText: "+addressBar.selectedText+ " addressBar.state: "+addressBar.state+ " initial selection: "+initialSelection)
                }
                if (!addressBar.selectedText
                        && addressBar.state === "selection") {
                    cutCopyRectangle.visible = false
                    cutCopyPasteRectangle.visible = false
                    selectSelectAllRectangle.visible = false

                    pasteRectangle.visible = true
                    pasteRectangle.x = ((topMarker.x + bottomMarker.x) / 2)
                            - (pasteRectangle.width / 2)
                } else if (addressBar.selectedText
                           && addressBar.state === "selection") {
                    cutCopyRectangle.visible = false
                    pasteRectangle.visible = false
                    selectSelectAllRectangle.visible = false

                    cutCopyPasteRectangle.visible = true
                    cutCopyPasteRectangle.x = ((topMarker.x + bottomMarker.x) / 2)
                            - (cutCopyPasteRectangle.width / 2)
                }
                else if (!addressBar.selectedText
                                           && addressBar.state === "") {
                    addressBar.cursorPosition = addressBar.positionAt(mouse.x)

                    cutCopyRectangle.visible = false
                    pasteRectangle.visible = false
                    cutCopyPasteRectangle.visible = false

                    selectSelectAllRectangle.visible = true
                                    selectSelectAllRectangle.x = addressBar.x
                                }
            }
        }

        //TODO Dirty function for prefixing with http:// for now. Would be good if we can detect if site can do https and use that or else http
        function updateURL() {
            searchSuggestions.visible = false
            var uri = EnyoUtils.parseUri(addressBar.text)
            if ((EnyoUtils.isValidScheme(uri) && EnyoUtils.isUri(
                     addressBar.text,
                     uri))) {
                if (text.substring(0, 7) === "http://" || text.substring(
                            0,
                            8) === "https://" || text.substring(0,
                                                                6) === "ftp://"
                        || text.substring(0, 7) === "data://") {
                    webView.url = addressBar.text
                    progressBar.height = Units.gu(1 / 2)
                    loadingIndicator.source = "images/menu-icon-stop.png"
                    //Show the lock in case of https
                    if (text.substring(0, 8) === "https://") {
                        isSecureSite = true
                        secureSite.visible = true
                        secureSite.width = Units.gu(3.75)
                        addressBar.width = navigationBar.width - forwardImage.width
                                - backImage.width - shareImage.width - newCardImage.width
                                - bookmarkImage.width - secureSite.width - 20
                    } else {
                        secureSite.visible = false
                        secureSite.width = Units.gu(0)
                        addressBar.width = navigationBar.width - forwardImage.width
                                - backImage.width - shareImage.width - newCardImage.width
                                - bookmarkImage.width - secureSite.width - 20
                    }
                } else {
                    webView.url = "http://" + addressBar.text
                    addressBar.text = "http://" + addressBar.text
                    progressBar.height = Units.gu(1 / 2)
                    loadingIndicator.source = "images/menu-icon-stop.png"
                }
            } else {
                //Just do a search with the default search engin
                webView.url = defaultSearchURL.replace("#{searchTerms}",
                                                       addressBar.text)
            }
        }

        states: [
            State {
                name: "selection"
            }
        ]
    }

    Image {
        id: shareImage
        anchors.left: addressBar.right
        anchors.verticalCenter: navigationBar.verticalCenter
        source: "images/menu-icon-share.png"
        height: Units.gu(4)
        width: Units.gu(4)
        clip: true
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: Image.AlignTop
        opacity: 0.5

        MouseArea {
            anchors.fill: parent

            onPressed: {
                if (webView.canGoBack) {
                    shareOptionsList.visible = !shareOptionsList.visible
                }
            }
            onReleased: {
                if (webView.canGoBack) {
                    shareImage.verticalAlignment = Image.AlignTop
                    shareImage.opacity = 1
                }
            }
        }
    }

    Image {
        id: newCardImage
        anchors.left: shareImage.right
        anchors.verticalCenter: navigationBar.verticalCenter
        source: "images/menu-icon-newcard.png"
        height: Units.gu(4)
        width: Units.gu(4)
        clip: true
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: Image.AlignTop
        opacity: 1

        MouseArea {
            anchors.fill: parent

            onPressed: {
                if (shareOptionsList.visible) {
                    shareOptionsList.visible = false
                }

                if (root.enableDebugOutput) {
                    console.log("New Card Pressed")
                }
                newCardImage.verticalAlignment = Image.AlignBottom
                navigationBar.__launchApplication("org.webosports.app.browser",
                                                  "{}")
            }
            onReleased: {
                if (root.enableDebugOutput) {
                    console.log("New Card Released")
                }
                newCardImage.verticalAlignment = Image.AlignTop
            }
        }
    }

    Image {
        id: bookmarkImage
        anchors.left: newCardImage.right
        anchors.verticalCenter: navigationBar.verticalCenter
        source: "images/menu-icon-bookmark.png"
        height: Units.gu(4)
        width: Units.gu(4)
        clip: true
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: sidePanel.visible ? Image.AlignBottom : Image.AlignTop
        opacity: 1

        MouseArea {
            anchors.fill: parent

            onPressed: {
                if (shareOptionsList.visible) {
                    shareOptionsList.visible = false
                }

                root.dataMode = "bookmarks"
                navigationBar.__queryDB(
                            "find",
                            '{"query":{"from":"com.palm.browserbookmarks:1", "limit":32}}')

                navigationBar.__queryDB(
                            "find",
                            '{"query":{"from":"com.palm.browserhistory:1", "limit":50, "orderBy":"date"}}')

                bookmarkImage.verticalAlignment = Image.AlignBottom
                bookmarkImage.opacity = 1.0
                Qt.inputMethod.hide()
                sidePanel.visible ? sidePanel.visible = false : sidePanel.visible = true
            }
            onReleased: {
                bookmarkImage.verticalAlignment = Image.AlignTop
                bookmarkImage.opacity = 1
            }
        }
    }

    Image {
        id: vkbImage
        anchors.left: bookmarkImage.right
        anchors.verticalCenter: navigationBar.verticalCenter
        source: "images/icon-hide-keyboard.png"
        height: showVKBButton ? Units.gu(4) : 0
        width: showVKBButton ? Units.gu(4) : 0
        clip: true
        fillMode: Image.PreserveAspectCrop
        visible: showVKBButton ? true : false
        opacity: 1

        MouseArea {
            anchors.fill: parent

            onPressed: {
                if (shareOptionsList.visible) {
                    shareOptionsList.visible = false
                }

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

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
    property var searchResultsAll: ['{}']
    width: parent.width
    height: Units.gu(5.2)
    color: "#343434"

    Component.onCompleted: navigationBar.__getDefaultSearch()

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

    function setFocus(focusState){
        if (root.enableDebugOutput) {
            console.log("setFocus called with"+focusState)
        }
        addressBar.focus = focusState;
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
                '{"query":{"from":"com.palm.browserhistory:1", "where":[{"prop":"searchText", "op":"?", "val":'+"\""+addressBar.text+"\""+', "collate":"primary"}], "orderBy": "_rev", "desc": true}}')
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
            console.log("Queried History DB : " + JSON.stringify(message.payload))
        }

        searchResultsHistory = JSON.parse(message.payload)

        //We need to put the icon for each of the types (bookmarks/history) so we put them in a new combined array
        var searchResults = []

        for (var j = 0, t; t = searchResultsBookmarks.results[j]; j++) {
            searchResults.push({url:t.url, title: t.title, icon: "images/header-icon-bookmarks.png"})
        }
        if(searchResultsHistory.results.length <= 32)
        {
            for (var i = 0, s; s = searchResultsHistory.results[i]; i++) {
                searchResults.push({url: s.url, title: s.title, icon:"images/header-icon-history.png"})
            }
        }

        //Stringify them so we can use it in the JSONList
        searchResultsAll = JSON.stringify(searchResults);
        return searchResultsAll

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
        var defbrows = JSON.parse(message.payload)
        defaultSearch = defbrows.SearchPreference.defaultSearchEngine
        luna.call("luna://com.palm.universalsearch/getUniversalSearchList",
                  JSON.stringify("{}"), __handleGetSearchSuccess,
                  __handleGetDefaultSearchError)
    }

    function __handleGetSearchSuccess(message) {
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
        verticalAlignment: Image.AlignTop
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
        width: navigationBar.width - forwardImage.width - backImage.width
               - shareImage.width - newCardImage.width - bookmarkImage.width - vkbImage.width - Units.gu(2.5)
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

        onActiveFocusChanged:
        {
            Qt.inputMethod.show()
        }

        onContentSizeChanged: {
            addressBarWidth = addressBar.width
            //We need a different query in case the lenght is 0
            if(addressBar.text.length === 0)
            {
                navigationBar.__queryDB(
                            "find",
                            '{"query":{"from":"com.palm.browserbookmarks:1"}}')
            }
            else
            {
                navigationBar.__queryDB(
                "search",
                '{"query":{"from":"com.palm.browserbookmarks:1", "where":[{"prop":"searchText", "op":"?", "val":'+"\""+addressBar.text+"\""+', "collate":"primary"}], "orderBy": "_rev", "desc": true}}')
            }
            optSearch.text = defaultSearchDisplayName
            imgSearch.source = defaultSearchIcon
            suggestionsBackground.height = (urlModel.count + 1) * Units.gu(6)
            suggestionList.height = (urlModel.count) * Units.gu(6)

            if (addressBar.text.length === 0 || addressBar.text.substring(
                        0, 4) === "http") {
                suggestionsBackground.visible = false
            } else {
                suggestionsBackground.visible = true
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

            states: [
                State {
                    name: "hideProgress"
                    when: webView.loadProgress === 100
                    PropertyChanges {
                        target: loadingIndicator
                        source: "images/menu-icon-refresh.png"
                    }
                }
            ]

            transitions: Transition {
                from: ""
                to: "hideProgress"
                PropertyAnimation {
                    target: loadingIndicator
                    properties: "opacity"
                    duration: 200
                }
            }

            //Handle stop/reload
            MouseArea {
                anchors.fill: loadingIndicator

                onPressed: {
                    if (webView.canGoBack) {
                        backImage.opacity = 1
                    }
                    if (webView.canGoForward) {
                        forwardImage.opafcity = 1
                    }

                    //TODO: Work out a more proper way of dealing with this. It works currently but it's not pretty
                    var myString = "'" + loadingIndicator.source
                    var mySplit = myString.split("/")
                    if (mySplit[mySplit.length - 1] === 'menu-icon-refresh.png') {

                        if (addressBar.text !== "") {
                            pb2.height = Units.gu(1 / 2)
                            pb2.value = 0
                        }
                        webView.reload
                        loadingIndicator.source = "images/menu-icon-stop.png"
                    } else {
                        if (addressBar.selectedText !== "") {
                            addressBar.deselect
                            addressBar.focus = true
                            Qt.inputMethod.show()
                        } else {
                            webView.stop
                            loadingIndicator.source = "images/menu-icon-refresh.png"
                            if (!alwaysShowProgressBar) {
                                pb2.height = 0
                            }
                            pb2.value = 0
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
                        pb2.height = 0
                    }
                }

                if (addressBar.selectedText === "") {
                    loadingIndicator.source = "images/menu-icon-refresh.png"
                    urlTimer.stop
                }
                if (webView.canGoBack) {
                    backImage.opacity = 1.0
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
                    pb2.progressBarColor = "green"
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
            onPressed: {
                if (webViewItem.url !== "" && addressBar.text !== "") {
                    addressBar.focus = true
                    Qt.inputMethod.show()

                    if(addressBar.selectedText!==addressBar.text)
                    {
                        addressBar.selectAll()
                        loadingIndicator.source = "images/menu-icon-stop.png"
                    }
                } else {
                    addressBar.deselect
                    addressBar.focus = true
                    Qt.inputMethod.show()
                }
            }
        }

        //TODO Dirty function for prefixing with http:// for now. Would be good if we can detect if site can do https and use that or else http
        function updateURL() {
            suggestionsBackground.visible = false
            var uri = EnyoUtils.parseUri(addressBar.text)
            if ((EnyoUtils.isValidScheme(uri) && EnyoUtils.isUri(
                     addressBar.text,
                     uri)) /*|| (enyo.windowParams.allowAllSchemes && uri.scheme) */) {
                if (text.substring(0, 7) === "http://" || text.substring(
                            0,
                            8) === "https://" || text.substring(0,
                                                                6) === "ftp://"
                        || text.substring(0, 7) === "data://") {
                    webView.url = addressBar.text
                    pb2.height = Units.gu(1 / 2)
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
                    pb2.height = Units.gu(1 / 2)
                    loadingIndicator.source = "images/menu-icon-stop.png"
                }
            } else {
                //Just do a search with the default search engine
                webView.url = defaultSearchURL.replace("{$query}",
                                                       addressBar.text)
            }
        }
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
        opacity: 1

        MouseArea {
            anchors.fill: parent

            onPressed: {
                shareOptions.visible = true

                var msg = ("Here's a website I think you'll like: <a href=\"{$src}\">{$title}</a>")
                msg = EnyoUtils.macroize(msg, {
                                             src: webViewItem.url,
                                             title: webViewItem.title
                                                    || webViewItem.url
                                         })
                var params = {
                    summary: ("Check out this web page..."),
                    text: msg
                }
                navigationBar.__launchApplication({
                                                      id: "com.palm.app.email",
                                                      params: params
                                                  })
            }
            onReleased: {
                shareImage.verticalAlignment = Image.AlignTop
                shareImage.opacity = 1
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
                if(Qt.inputMethod.visible)
                {
                    Qt.inputMethod.hide()
                }
                else
                {
                    addressBar.focus = true
                    Qt.inputMethod.show()
                }
            }
        }
    }

    Rectangle {
        id: suggestionsBackground
        color: "#DADADA"
        anchors.left: parent.left
        anchors.top: parent.bottom
        anchors.leftMargin: Screen.width < 900 ? 0 : isSecureSite ? Units.gu(12.75) : Units.gu (9)
        width: Screen.width < 900 ? navigationBar.width : addressBarWidth
        radius: 4
        visible: false
        height: (urlModel.count + 1) * Units.gu(6)

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
                    suggestionsBackground.visible = false
                    webViewItem.url = defaultSearchURL.replace("{$query}",
                                                               addressBar.text)
                    addressBar.text = defaultSearchURL.replace("{$query}",
                                                               addressBar.text)
                }
            }

            Text {
                id: optSearch
                text: navigationBar.defaultSearchDisplayName + " \"" + addressBar.text + "\""
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: Units.gu(2)
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                font.pixelSize: FontUtils.sizeToPixels("large")
                font.family: "Prelude"
                color: "#494949"
                height: Units.gu(6)
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
                    source: navigationBar.defaultSearchIcon
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

            JSONListModel {
                id: urlModel
                json: getURLHistory()
                query: "$[*]"

                function getURLHistory()
                {
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
                                                         addressBar.text)
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
                                                             addressBar.text)
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
                    z:2

                    Image {
                        source: model.icon
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
                        suggestionsBackground.visible = false
                        webViewItem.url = model.url
                        addressBar.text = model.url
                    }
                }
                Component.onCompleted:
                {
                    suggestionsBackground.height = (urlModel.count + 1) * Units.gu(6)
                    suggestionList.height = (urlModel.count) * Units.gu(6)
                }
            }
        }
    }
}


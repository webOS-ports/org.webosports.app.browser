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
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import QtTest 1.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import LunaNext.Common 0.1
import "Utils"


Window {


    id: root
    width: 800
    height: 600

    UserAgent {
        id: userAgent
    }

    Tweak {
        id: privateByDefaultTweak
        owner: "org.webosports.app.browser"
        key: "privateByDefaultKey"
        defaultValue: "false"
        onValueChanged: updatePrivateByDefault()

        function updatePrivateByDefault() {
            if (privateByDefaultTweak.value === true) {
                privateByDefault = true
            } else {
                privateByDefault = false
            }
            if (enableDebugOutput) {
                console.log("privateByDefault: " + privateByDefault)
            }
        }
    }

    /////// private //////
    LunaService {
        id: luna
        name: "org.webosports.app.browser"
    }

    function __launchApplication(id, params) {
        console.log("launching app " + id + " with params " + params.toString())
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
        luna.call("luna://com.palm.db/" + action, params,
                  __handleQueryDBSuccess, __handleQueryDBError)
    }

    function __handleQueryDBError(message) {
        console.log("Could not query DB : " + message)
    }

    function __handleQueryDBSuccess(message) {
        if (dataMode === "bookmarks") {
            myBookMarkData = message.payload
        } else if (dataMode === "downloads") {
            myDownloadsData = '{"results":[{"url":"Downloads not implemented yet", "title":"Downloads not implemented yet"}]}'
        } else if (dataMode === "history") {
            myHistoryData = message.payload
        }
    }

    function __queryPutDB(myData) {
        if (enableDebugOutput) {
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
        if(enableDebugOutput)
        {
            console.log("Put DB: " + JSON.stringify(message.payload))
        }
    }

    property bool pageIsLoading: false
    property bool historyAvailable: false
    property bool forwardAvailable: false
    property bool enableDebugOutput: true
    property string myBookMarkData: '{}'
    property string myDownloadsData: '{}'
    property string myHistoryData: '{}'
    property string dataMode: "bookmarks"
    property bool privateByDefault: false

    /* Without this line, we won't ever see the window... */
    Component.onCompleted:
    {
        root.visible = true
        //Run query so we have the bookmarks item on first load of the panel
        root.__queryDB(
                    "find",
                    '{"query":{"from":"com.palm.browserbookmarks:1", "limit":32}}')

        var lparams = JSON.parse(application.launchParameters)
        if (lparams.target && lparams.target.length > 0)
            webViewItem.url = lparams.target
    }

    Connections {
        target: application // this is luna-qml-launcher C++ object instance
        onRelaunched: console.log(
                          "The browser has been relaunched with parameters: " + parameters)
    }

    NavigationBar {
        id: navigationBar
        webView: webViewItem
        z: 2
    }

    WebView {
        id: webViewItem
        anchors.top: pb2.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        experimental.preferences.fullScreenEnabled: true
        experimental.preferences.developerExtrasEnabled: true
        experimental.preferences.webGLEnabled: true
        experimental.preferences.webAudioEnabled: true
        experimental.preferences.dnsPrefetchEnabled: true
        experimental.preferences.navigatorQtObjectEnabled: true
        experimental.userAgent: userAgent.defaultUA
        visible: true
        z: 1

        onNavigationRequested: {
            pb2.height = Units.gu(1/2)
            request.action = WebView.AcceptRequest;

            if (request.action === WebView.IgnoreRequest)
                return;

            var staticUA = undefined
            if (staticUA === undefined) {
                if(enableDebugOutput)
                webViewItem.experimental.userAgent = userAgent.getUAString(request.url)
            } else {
                webViewItem.experimental.userAgent = staticUA
            }
        }



        //Add the "gray" background when no page is loaded and show the globe. This does feel like legacy doesn't it?
        Image {
            id: webViewBackground
            source: "images/background-startpage.png"
            anchors.fill: parent
            Image {
                id: webViewPlaceholder
                y: Units.gu(3)
                anchors.horizontalCenter: parent.horizontalCenter
                source: "images/startpage-placeholder.png"
            }
        }

        onLoadingChanged: {

            if (loadRequest.status == WebView.LoadStartedStatus)
                pageIsLoading = true
                pb2.height = Units.gu(1/2)
                console.log("Loading started...")
            if (loadRequest.status == WebView.LoadFailedStatus) {
                console.log("Load failed! Error code: " + loadRequest.errorCode)
                webViewItem.loadHtml("Failed to load " + loadRequest.url, "",
                                     loadRequest.url)
                pageIsLoading = false
                if (loadRequest.errorCode === NetworkReply.OperationCanceledError)
                    console.log("Load cancelled by user")
                webViewItem.loadHtml(
                            "Loading of " + loadRequest.url + " cancelled by user",
                            "", loadRequest.url)
                pageIsLoading = false
            }
            if (loadRequest.status == WebView.LoadSucceededStatus)
                pageIsLoading = false

            console.log("Page loaded!")

                if(webViewItem.loadProgress === 100)
                {
                    //Brought this back from legacy to make sure that we don't clutter the history with multiple items for the same website ;)
                    //Only create history item in case we're not using Private Browsing
                    if (!privateByDefault){
                    navigationBar.__queryDB("del", '{"query":{"from":"com.palm.browserhistory:1", "where":[{"prop":"url", "op":"=", "val":"'+webViewItem.url+'"}]}}')

                     var history = {
                        _kind: "com.palm.browserhistory:1",
                        url: "" + webViewItem.url,
                        title: "" + webViewItem.title,
                        date: (new Date()).getTime()
                     }

                         //Put the URL in browser history after the page is loaded successfully :)
                         navigationBar.__queryPutDB(history)
                     } else {
                         if (enableDebugOutput) {
                            console.log("Private browsing enabled so we don't create a history entry")
                         }
                     }
                }

        }

        url: ""
    }

    Rectangle {
        id: shareOptions
        height: Units.gu(15)
        width: Units.gu(17)
        anchors.top: navigationBar.bottom
        anchors.horizontalCenter: navigationBar.horizontalCenter
        anchors.horizontalCenterOffset: Units.gu(28)
        visible: false
        radius: 4
        color: "#E5E5E5"
        z: 2

        ListModel {
            id: shareOptionsModel
            ListElement {
                action: "Add Bookmark"
            }
            ListElement {
                action: "Share Link"
            }
            ListElement {
                action: "Add to Launcher"
            }
        }
        Component {
            id: shareOptionsDelegate
            Rectangle {
                id: shareOptionsDelegateRect
                color: "#E5E5E5"
                border.width: 10
                border.color: "#ffffff"
                height: Units.gu(4.5)
                x: Units.gu(1.5)
                Text {
                    y: Units.gu(1.5)
                    text: action
                    font.family: "Prelude"
                    font.pixelSize: FontUtils.sizeToPixels("medium")
                    verticalAlignment: Text.AlignVCenter
                }
                Rectangle {
                    id: optionDivider
                    color: "black"

                    width: shareOptionsDelegateRect.width
                    height: Units.gu(19)
                    anchors.top: shareOptionsDelegateRect.bottom
                }
            }
        }

        ListView {
            anchors.fill: parent
            model: shareOptionsModel
            delegate: shareOptionsDelegate
        }
    }

    ProgressBar {
        id: pb2
        property int minimum: 0
        property int maximum: 100
        property int value: 0
        property string progressBarColor: "#2E8CF7"

        z: 1
        minimumValue: 0
        maximumValue: 100
        height: pageIsLoading ? Units.gu(1/2) : 0
        visible: true
        anchors.top: navigationBar.bottom
        style: ProgressBarStyle {
            background: Rectangle {
                radius: 2
                color: "darkgray"
                border.color: "gray"
                border.width: 1
                implicitWidth: navigationBar.width
                implicitHeight: Units.gu(1 / 2)
            }
            progress: Rectangle {
                id: progressRect
                color: pb2.progressBarColor
                border.color: pb2.progressBarColor
            }
        }
    }

    Rectangle {
        id: sidePanel
        height: parent.height
        width: Screen.width < 900 ? Screen.width : Units.gu(32)
        anchors.right: parent.right
        color: "#E5E5E5"
        visible: false
        z: 2

        onActiveFocusChanged:
        {
            Qt.inputMethod.show()
        }


        Rectangle {
            id: sidePanelHeader
            height: Units.gu(5.2)
            width: parent.width
            color: "#343434"
            anchors.top: parent.top
            anchors.left: parent.left
            visible: true
            z: 3
            Rectangle {
                id: buttonRow
                width: Screen.width < 900 ? parent.width : Units.gu(30)
                height: Units.gu(4)
                x: Units.gu(1)
                radius: 4
                color: "transparent"
                anchors.verticalCenter: parent.verticalCenter
                visible: true
                z:3

                Rectangle {
                    id: bookmarkButton
                    implicitWidth: Screen.width < 900 ? ((parent.width - Units.gu(2)) /3) : Units.gu(10)
                    implicitHeight: Units.gu(4)
                    anchors.left: buttonRow.left
                    color: "transparent"

                    Image {
                        id: bookmarkButtonImage
                        source: "images/radiobuttondarkleftpressed.png"
                        anchors.fill: parent
                        anchors.left: bookmarkButton.left
                        MouseArea {
                            anchors.fill: bookmarkButtonImage
                            onClicked: {
                                dataMode = "bookmarks"
                                root.__queryDB(
                                            "find",
                                            '{"query":{"from":"com.palm.browserbookmarks:1", "limit":32}}')
                                bookmarkButtonImage.source = "images/radiobuttondarkleftpressed.png"
                                bookmarkButtonImageInside.verticalAlignment = Image.AlignBottom
                                addBookMark.visible = true

                                historyButtonImage.source = "images/radiobuttondarkmiddle.png"
                                historyButtonImageInside.verticalAlignment = Image.AlignTop

                                downloadButtonImage.source = "images/radiobuttondarkright.png"
                                downloadButtonImageInside.verticalAlignment = Image.AlignTop
                                clearDownloads.visible = false
                            }
                        }

                        Image {
                            id: bookmarkButtonImageInside
                            source: "images/toaster-icon-bookmarks.png"
                            height: Units.gu(4)
                            width: Units.gu(4)
                            clip: true
                            fillMode: Image.PreserveAspectCrop
                            verticalAlignment: Image.AlignBottom
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                Rectangle {
                    id: historyButton
                    implicitWidth: Screen.width < 900 ? ((parent.width - Units.gu(2)) /3) : Units.gu(10)
                    implicitHeight: Units.gu(4)
                    anchors.left: bookmarkButton.right
                    color: "transparent"
                    Image {
                        id: historyButtonImage
                        anchors.fill: parent
                        source: "images/radiobuttondarkmiddle.png"
                        anchors.left: parent.left

                        MouseArea {
                            anchors.fill: historyButtonImage
                            onClicked: {
                                dataMode = "history"
                                root.__queryDB(
                                            "find",
                                            '{"query":{"from":"com.palm.browserhistory:1", "limit":50, "orderBy":"date"}}')
                                bookmarkButtonImage.source = "images/radiobuttondarkleft.png"
                                bookmarkButtonImageInside.verticalAlignment = Image.AlignTop

                                addBookMark.visible = false

                                historyButtonImage.source
                                        = "images/radiobuttondarkmiddlepressed.png"
                                historyButtonImageInside.verticalAlignment = Image.AlignBottom

                                downloadButtonImage.source = "images/radiobuttondarkright.png"
                                downloadButtonImageInside.verticalAlignment = Image.AlignTop
                                clearDownloads.visible = false
                            }
                        }

                        Image {
                            id: historyButtonImageInside
                            source: "images/toaster-icon-history.png"
                            height: Units.gu(4)
                            width: Units.gu(4)
                            clip: true
                            fillMode: Image.PreserveAspectCrop
                            verticalAlignment: Image.AlignTop
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
                Rectangle {
                    id: downloadButton
                    implicitWidth: Screen.width < 900 ? ((parent.width - Units.gu(2)) /3) : Units.gu(10)
                    implicitHeight: Units.gu(4)
                    anchors.left: historyButton.right
                    color: "transparent"

                    Image {
                        id: downloadButtonImage
                        source: "images/radiobuttondarkright.png"
                        anchors.fill: parent
                        anchors.left: parent.left

                        MouseArea {
                            anchors.fill: downloadButtonImage
                            onClicked: {
                                dataMode = "downloads"
                                //TODO Mocked some data for now until we have the DownloadManager ready
                                myDownloadsData = '{"results":[{"url":"", "title":"Downloads not implemented yet"}]}'

                                downloadButtonImage.source
                                        = "images/radiobuttondarkrightpressed.png"
                                downloadButtonImageInside.verticalAlignment = Image.AlignBottom

                                historyButtonImage.source = "images/radiobuttondarkmiddle.png"
                                historyButtonImageInside.verticalAlignment = Image.AlignTop

                                bookmarkButtonImage.source = "images/radiobuttondarkmiddle.png"
                                bookmarkButtonImageInside.verticalAlignment = Image.AlignTop
                                addBookMark.visible = false
                                clearDownloads.visible = true
                            }
                        }

                        Image {
                            id: downloadButtonImageInside
                            source: "images/toaster-icon-downloads.png"
                            height: Units.gu(4)
                            width: Units.gu(4)
                            clip: true
                            fillMode: Image.PreserveAspectCrop
                            verticalAlignment: Image.AlignTop
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }

        Rectangle {
            id: sidePanelBody
            height: parent.height - sidePanelHeader.height - sidePanelFooter.height
            width: parent.width
            color: "#E5E5E5"
            anchors.top: sidePanelHeader.bottom
            visible: true
            z:2

            ListView {
                anchors.top: sidePanelBody.top
                id: dataList
                width: parent.width
                height: parent.height
                JSONListModel {
                    id: dataModel
                    json: getJSONData()

                    query: "$.results[*]"

                    function getJSONData() {
                        if (dataMode === "bookmarks") {
                            return myBookMarkData
                        } else if (dataMode === "downloads") {
                            return myDownloadsData
                        } else if (dataMode === "history") {
                            return myHistoryData
                        }
                        else
                        {
                            return "'{}'"
                        }

                    }
                }

                model: dataModel.model

                delegate: Rectangle {
                    id: dataSectionRect
                    height: Units.gu(6)
                    width: parent.width
                    anchors.left: parent.left
                    color: "transparent"

                    Rectangle {
                        id: dataResultsRect
                        height: Units.gu(6)
                        anchors.left: dataSectionRect.left
                        anchors.top: parent.top
                        color: "transparent"
                        width: dataMode === "history" ? Units.gu(
                                                            4) : Units.gu(1)

                        Image {
                            id: dataResultsImage
                            source: dataMode === "history" ? "images/header-icon-history.png" : ""
                            anchors.top: dataResultsRect.top
                            anchors.left: dataResultsRect.left
                            height: Units.gu(3)
                            width: Units.gu(3)
                            anchors.topMargin: Units.gu(1.5)
                            anchors.leftMargin: Units.gu(1)
                            horizontalAlignment: Image.AlignLeft
                        }
                    }

                    Text {
                        id: dataUrlTitle
                        anchors.top: dataSectionRect.top
                        anchors.topMargin: Units.gu(0.75)
                        height: dataSectionRect.height
                        width:  dataMode === "history" ? parent.width - Units.gu(5) : parent.width - Units.gu(2)
                        anchors.left: dataResultsRect.right
                        anchors.leftMargin: Units.gu(0.5)
                        clip: true
                        horizontalAlignment: Text.AlignLeft
                        font.family: "Prelude"
                        font.pixelSize: FontUtils.sizeToPixels("large")
                        color: "#494949"
                        elide: Text.ElideRight
                        text: model.title || ""
                        Text {
                            height: parent.height
                            id: url
                            clip: true
                            anchors.top: dataUrlTitle.top
                            anchors.topMargin: Units.gu(0.75)
                            verticalAlignment: Text.AlignVCenter
                            anchors.left: dataUrlTitle.left
                            horizontalAlignment: Text.AlignRight
                            font.family: "Prelude"
                            font.pixelSize: FontUtils.sizeToPixels("small")
                            text: model.url || ""
                            color: "#838383"
                        }
                    }
                    Rectangle {
                        color: "silver"
                        height: Units.gu(1 / 10)
                        width: parent.width
                        anchors.top: dataSectionRect.top
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            sidePanel.visible = false
                            webViewItem.url = model.url
                        }
                    }
                }
            }
        }

        Rectangle {
            id: sidePanelFooter
            height: Units.gu(5.2)
            width: parent.width
            color: "#343434"
            anchors.bottom: parent.bottom
            visible: true
            z: 3

            Image {
                id: dragHandle
                source: "images/drag-handle.png"
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: dragHandle
                    onClicked: {
                        navigationBar.setFocus(true)
                        sidePanel.visible = false

                    }
                }
            }

            Image {
                id: addBookMark
                source: "images/menu-icon-add.png"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                clip: true
                height: Units.gu(4)
                width: Units.gu(4)
                fillMode: Image.PreserveAspectCrop
                verticalAlignment: Image.AlignTop
                visible: true

                MouseArea {
                    anchors.fill: addBookMark
                    onClicked: {
                        addBookMark.verticalAlignment = Image.AlignBottom
                        var date = (new Date()).getTime()
                        var bookMarkEntry = {
                            _kind: "com.palm.browserbookmarks:1",
                            url: "" + webViewItem.url,
                            title: webViewItem.title,
                            date: date,
                            lastVistited: date,
                            defaultEntry: false,
                            visitCount: 0,
                            idx: null
                        }

                        root.__queryPutDB(bookMarkEntry)
                        root.__queryDB(
                                    "find",
                                    '{"query":{"from":"com.palm.browserbookmarks:1", "limit":32}}')


                    }
                    onReleased: {
                        addBookMark.verticalAlignment = Image.AlignTop
                    }
                    onExited: {
                        addBookMark.verticalAlignment = Image.AlignTop
                    }
                }
            }

            Rectangle {
                id: clearDownloads
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: sidePanelFooter.right
                anchors.rightMargin: Units.gu(2)
                height: Units.gu(3.5)
                width: Units.gu(6)
                radius: 4
                color: "transparent"
                border.width: 1
                border.color: "#2D2D2D"
                visible: false

                Text {
                    id: clearDownloadsText
                    text: "Clear"
                    color: "#E5E5E5"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: "Prelude"
                    font.pixelSize: FontUtils.sizeToPixels("medium")
                }

                MouseArea {
                    anchors.fill: clearDownloads
                    onClicked: {
                        //TODO need to do proper handling once Download Manager is there
                        console.log("clearDownloads clicked, ")
                    }
                }
            }
        }

        //Add a timer for our progress bar
        Timer {
            running: true
            repeat: true
            interval: 10
            onTriggered: {
                //disable the background, otherwise it won't show the page
                if (pageIsLoading) {
                    pb2.progressBarColor = "#2E8CF7"
                    webViewBackground.source = ""
                    webViewPlaceholder.source = ""
                }
                //Update ProgressBar (this one is more accurate compared to legacy :))
                pb2.value = webViewItem.loadProgress
            }
        }
    }
}

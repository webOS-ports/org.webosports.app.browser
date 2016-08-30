/*
* Copyright (C) 2014 Simon Busch <morphis@gravedo.de>
* Copyright (C) 2014 Herman van Hazendonk <github.com@herrie.org>
* Copyright (C) 2014 Christophe Chapuis <chris.chapuis@gmail.com>
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
import QtWebEngine 1.2
import QtWebEngine.experimental 1.0
import QtWebChannel 1.0
import Qt.labs.settings 1.0

import LunaNext.Common 0.1
import LuneOS.Components 1.0
import LuneOS.Service 1.0

import browserutils 0.1
import "js/util-uri.js" as EnyoUriUtils

import "AppTweaks"
import "Models"

LunaWebEngineView {
    id: webViewItem
    profile.httpUserAgent: userAgent.defaultUA

    url: ""

    property bool internetAvailable: false
    property HistoryDbModel historyDbModel

    signal openNewCard(string urlToOpen);
    signal openContextualMenu(var contextMenuData);

    readonly property string webViewBackgroundSource: "images/background-startpage.png"
    readonly property string webViewPlaceholderSource: "images/startpage-placeholder.png"

    LunaService {
        id: service
        name: "org.webosports.app.browser"
        usePrivateBus: true
    }

    onJavaScriptConsoleMessage: console.warn("CONSOLE JS: " + message);

    onFullScreenRequested: {
        if (request.toggleOn) {
            service.call("luna://org.webosports.luna/enableFullScreenMode",
                         JSON.stringify({"enable": true}),
                         undefined, undefined);
        } else {
            service.call("luna://org.webosports.luna/enableFullScreenMode",
                         JSON.stringify({"enable": false}),
                         undefined, undefined);
        }
        request.accept();
    }

    visible: true

    userScripts: [
        WebEngineScript {
            name: "qwebchannel";
            sourceUrl: Qt.resolvedUrl("js/qwebchannel.js");
            injectionPoint: WebEngineScript.DocumentCreation;
            worldId:WebEngineScript.MainWorld;
        },
         WebEngineScript {
             name: "userscript";
             sourceUrl: Qt.resolvedUrl("js/userscript.js");
             injectionPoint: WebEngineScript.Deferred;
             worldId:WebEngineScript.MainWorld;
        },
        WebEngineScript {
            name: "setupViewport";
            sourceUrl: Qt.resolvedUrl("js/setupViewport.js");
            injectionPoint: WebEngineScript.DocumentReady;
            worldId:WebEngineScript.MainWorld;
       }
    ]

    webChannel.registeredObjects: [messageHelper]

    QtObject {
        id: messageHelper
        WebChannel.id: "messageHelper"

        function onMessageReceived(message) {
            var data = null
            try {
                data = JSON.parse(message)
            } catch (error) {
                console.log('onMessageReceived: ' + message)
                return
            }
            switch (data.type) {
            case 'link':
                //In case we're having a relative URL we need to prefix it with the proper baseURL.
                if (data.href.indexOf("://") === -1) {
                    data.href = EnyoUriUtils.get_host(webViewItem.url) + data.href
                }

                if (data.target === '_blank') {
                    // open link in new tab
                    webViewItem.openNewCard(data.href)
                } else if (data.target && data.target !== "_parent") {
                    //Nasty hack to prevent URLs ending with # to open in a new card where they shouldn't.
                    if (data.href.slice(-1) !== "#") {
                        webViewItem.openNewCard(data.href)
                    }
                }
                break
            case 'longpress':
                if (data.href && data.href !== "CANT FIND LINK")
                    webViewItem.openContextualMenu(data)
                break
            }
        }
    }

    BrowserUtils {
        id: utils
        webview: webViewItem
    }

    readonly property size thumbnail_size: Qt.size(90, 120)
    property bool viewImageCreated: false
    property string thumbnail: ""
    property string icon64: ""

    function createViewImage() {
        var t = (new Date()).getTime()
        var p = "/var/luna/data/browser/icons/"
        thumbnail = p + "thumbnail-" + t + ".png"
        icon64 = p + "icon64-" + t + ".png"
        utils.saveViewToFile(thumbnail, thumbnail_size)
        viewImageCreated = true
    }

    function createIconImages() {
        viewImageCreated = false
        utils.generateIconFromFile(thumbnail, icon64, thumbnail_size)
        bookmarkDialog.myBookMarkIcon = icon64
    }

    //Nasty but works, we need a delay of 1000+ ms in order to be able to create the icons, because the viewImage has a delay of 1000ms
    Timer {
        interval: 1500
        running: viewImageCreated && webViewItem.loadProgress === 100
        repeat: true
        onTriggered: createIconImages()
    }
/*
    onNavigationRequested: {
        //Hide VKB
        Qt.inputMethod.hide()

        progressBar.height = Units.gu(1 / 2)
        request.action = WebView.AcceptRequest

        if (request.action === WebView.IgnoreRequest)
            return

        var staticUA = undefined
        if (staticUA === undefined) {
            if (enableDebugOutput)
                webViewItem.experimental.userAgent = userAgent.getUAString(
                            request.url)
        } else {
            webViewItem.experimental.userAgent = staticUA
        }
    }
*/

    onLoadingChanged: {
        if (loadRequest.status == WebEngineView.LoadStartedStatus) {
            console.log("Loading started...")
            loadingProgressBarItem.show();
            webViewBackground.visible = false;
        }
        else if (loadRequest.status == WebEngineView.LoadFailedStatus) {
            console.log("Load failed! Error code: " + loadRequest.errorCode)
            webViewItem.loadHtml("Failed to load " + loadRequest.url, "",
                                 loadRequest.url)

            if (loadRequest.errorCode === NetworkReply.OperationCanceledError
                    && internetAvailable) {
                console.log("Load cancelled by user")
                webViewItem.loadHtml(
                            "Loading of " + loadRequest.url + " cancelled by user",
                            "", loadRequest.url)
            }
            else if (loadRequest.errorCode === NetworkReply.OperationCanceledError
                    && !internetAvailable) {
                console.log("No internet connection available")
                console.log("loadRequest.status: " + loadRequest.status
                            + " loadRequest.errorCode: " + loadRequest.errorCode
                            + " loadRequest.errorString: " + loadRequest.errorString)
                webViewItem.loadHtml(
                            "No internet connection available, cannot load " + loadRequest.url,
                            "", loadRequest.url)
            }
        }
        else if (loadRequest.status == WebEngineView.LoadSucceededStatus) {
            console.log("Page loaded!")
        }

        if (webViewItem.loadProgress === 100) {
            //Brought this back from legacy to make sure that we don't clutter the history with multiple items for the same website ;)
            //Only create history item in case we're not using Private Browsing
            if (!AppTweaks.privateByDefaultTweakValue) {

                //Create the icon/images for the page
                createViewImage()

                //Put the URL in browser history after the page is loaded successfully :)
                historyDbModel.addHistoryUrl(webViewItem.url, webViewItem.title, true);
            } else {
                if (enableDebugOutput) {
                    console.log("Private browsing enabled so we don't create a history entry")
                }
            }
        }
    }

    // Add a progress bar at the top of the webview
    MyProgressBar
    {
        id: loadingProgressBarItem
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        visible: false
        z: 1

        function show()
        {
            if(AppTweaks.progressBarTweakValue) visible = true;
        }
        Timer {
            interval: 100
            repeat: false
            running: !webViewItem.loading && loadingProgressBarItem.visible
            onTriggered: loadingProgressBarItem.visible = false
        }

        value: webViewItem.loadProgress / 100
    }

    //Add the "gray" background when no page is loaded and show the globe. This does feel like legacy doesn't it?
    Image {
        z: 1
        id: webViewBackground
        source: webViewBackgroundSource
        anchors.fill: parent
        Image {
            id: webViewPlaceholder
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -Qt.inputMethod.keyboardRectangle.height / 2.
            source: webViewPlaceholderSource
        }
    }
}


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
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import QtQuick 2.0

WebView {
    id: webViewItem
    anchors.top: progressBar.bottom
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    //experimental.preferences.fullScreenEnabled: true
    experimental.preferences.developerExtrasEnabled: true
    experimental.preferences.webGLEnabled: true
    experimental.preferences.webAudioEnabled: true
    experimental.preferences.dnsPrefetchEnabled: true
    experimental.preferences.navigatorQtObjectEnabled: true
    experimental.userAgent: userAgent.defaultUA
    experimental.authenticationDialog: AuthenticationDialog {
    }
    visible: true
    z: 1

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

    //Add the "gray" background when no page is loaded and show the globe. This does feel like legacy doesn't it?
    Image {
        id: webViewBackground
        source: "images/background-startpage.png"
        anchors.fill: parent
        Image {
            id: webViewPlaceholder
            y: Units.gu(3)
            anchors.horizontalCenter: parent.horizontalCenter
            //anchors.verticalCenter: parent.verticalCenter
            source: "images/startpage-placeholder.png"
        }
    }

    onLoadingChanged: {

        //Refresh connection status
        __getConnectionStatus()

        if (loadRequest.status == WebView.LoadStartedStatus)
            pageIsLoading = true
        progressBar.height = Units.gu(1 / 2)
        console.log("Loading started...")
        if (loadRequest.status == WebView.LoadFailedStatus) {
            console.log("Load failed! Error code: " + loadRequest.errorCode)
            webViewItem.loadHtml("Failed to load " + loadRequest.url, "",
                                 loadRequest.url)
            pageIsLoading = false
            if (loadRequest.errorCode === NetworkReply.OperationCanceledError
                    && internetAvailable)
                console.log("Load cancelled by user")
            webViewItem.loadHtml(
                        "Loading of " + loadRequest.url + " cancelled by user",
                        "", loadRequest.url)
            pageIsLoading = false

            if (loadRequest.errorCode === NetworkReply.OperationCanceledError
                    && !internetAvailable)
                console.log("No internet connection available")
            webViewItem.loadHtml(
                        "No internet connection available, cannot load " + loadRequest.url,
                        "", loadRequest.url)
            pageIsLoading = false
        }
        if (loadRequest.status == WebView.LoadSucceededStatus)
            pageIsLoading = false

        console.log("Page loaded!")

        if (webViewItem.loadProgress === 100) {
            //Brought this back from legacy to make sure that we don't clutter the history with multiple items for the same website ;)
            //Only create history item in case we're not using Private Browsing
            if (!privateByDefault) {
                navigationBar.__queryDB(
                            "del",
                            '{"query":{"from":"com.palm.browserhistory:1", "where":[{"prop":"url", "op":"=", "val":"' + webViewItem.url + '"}]}}')

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

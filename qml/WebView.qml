
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
import LunaNext.Common 0.1
import LuneOS.Components 1.0
import browserutils 0.1
import "js/util.js" as EnyoUtils

import "Utils"

WebView {
    property string webViewBackgroundSource: "images/background-startpage.png"
    property string webViewPlaceholderSource: "images/startpage-placeholder.png"
    id: webViewItem
    anchors.top: navigationBar.alwaysShowProgressBar?
    progressBar.bottom:navigationBar.bottom
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    //experimental.preferences.fullScreenEnabled: true
    experimental.preferences.developerExtrasEnabled: true
    experimental.preferences.fileAccessFromFileURLsAllowed: true
    experimental.preferences.javascriptEnabled: true
    experimental.preferences.localStorageEnabled: true
    experimental.preferences.webGLEnabled: true
    experimental.preferences.webAudioEnabled: true
    experimental.preferences.dnsPrefetchEnabled: true
    experimental.preferences.navigatorQtObjectEnabled: true
    experimental.preferences.standardFontFamily: "Prelude"
    experimental.userAgent: userAgent.defaultUA
    experimental.authenticationDialog: AuthenticationDialog {
        serverURL: webViewItem.url
        hostname: model.hostname
        onAccepted: {
            //TODO: Need to implement password manager using KeyManager where possible
            if (savePwd) {
                //TODO Function to call and do the password management
            }
            model.accept(username, pass);
        }
    }

    experimental.certificateVerificationDialog: CertDialog {
        onViewCertificate: { /*TODO*/ }
        onTrust: {
            model.accept();
            if(always) { /*TODO*/ }
        }
        onReject: {
            model.reject();
            webview.stop();
        }
    }
    experimental.proxyAuthenticationDialog: ProxyAuthenticationDialog {
        hostname: model.hostname
        port: model.port
        onAccepted: {
            //TODO: Need to implement password manager using KeyManager where possible
            if (savePwd) {
                //TODO Function to call and do the password management
            }
            model.accept(username, pass);
        }
    }
    experimental.alertDialog: AlertDialog {
        message: model.message
        onAccepted: model.dismiss();
    }
    experimental.confirmDialog: ConfirmDialog {
        message: model.message
        onAccepted: model.accept();
        onRejected: model.reject();
    }
    experimental.promptDialog: PromptDialog {
        message: model.message
        defaultValue: model.defaultValue
        onAccepted: model.accept(input.text);
        onRejected: model.reject();
    }
    experimental.filePicker: FilePicker {
        fileModel: model
    }
    experimental.itemSelector: ItemSelector {
        selectorModel: model;
    }

    visible: true
    z: 1

    property bool viewImageCreated: false;
    property string t: "" ;
    property int w: 90;
    property int h: 120;
    property string p: "" ;
    property string thumbnail: "" ;
    property string icon64: "";

    experimental.userScripts: [
        Qt.resolvedUrl("js/userscript.js")
    ]

    experimental.onMessageReceived: {
        var data = null
        try {
            data = JSON.parse(message.data)
        } catch (error) {
            console.log('onMessageReceived: ' + message.data );
            return
        }
        switch (data.type) {
        case 'link':
        {
            //In case we're having a relative URL we need to prefix it with the proper baseURL.
            if (data.href.indexOf("://") === -1) {
                data.href = EnyoUtils.get_host(webViewItem.url) + data.href
            }

            if (data.target === '_blank') {
                // open link in new tab
                window.openNewCard(data.href)
            } else if (data.target && data.target !== "_parent") {
                //Nasty hack to prevent URLs ending with # to open in a new card where they shouldn't.
                if (data.href.slice(-1) !== "#") {
                    window.openNewCard(data.href)
                }
            }
            break
        }
        case 'longpress':
        {
            if (data.href && data.href !== "CANT FIND LINK")
                contextMenu.show(data)
        }
        }
    }

    function createViewImage() {
        t = (new Date()).getTime();
        p = "/var/luna/data/browser/icons/";
        thumbnail = p + "thumbnail-" + t + ".png";
        icon64 = p + "icon64-" + t + ".png";
        utils.saveViewToFile(thumbnail,Qt.size(w,h));
        viewImageCreated = true;
    }

    BrowserUtils {
        id: utils
        webview: webViewItem
    }

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
        source: webViewBackgroundSource
        anchors.fill: parent
        Image {
            id: webViewPlaceholder
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset : -window.keyboardHeight/2.
            source: webViewPlaceholderSource
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
            console.log("loadRequest.status: "+loadRequest.status+" loadRequest.errorCode: "+loadRequest.errorCode+" loadRequest.errorString: "+loadRequest.errorString)
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

                //Create the icon/images for the page
                createViewImage();

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

    function createIconImages() {
        utils.generateIconFromFile(thumbnail, icon64, Qt.size(w,h));
        viewImageCreated = false;
        bookmarkDialog.myBookMarkIcon = icon64;
    }

    //Nasty but works, we need a delay of 1000+ ms in order to be able to create the icons, because the viewImage has a delay of 1000ms
    Timer  {
        interval: 1500; running: viewImageCreated && webViewItem.loadProgress === 100;
        repeat: true
        onTriggered: createIconImages();
    }

    url: ""
}

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
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import LunaNext.Common 0.1
import "js/util.js" as URLUtil


Rectangle {
    id: navigationBar

    property Item webView: null

    width: parent.width
    height: Units.gu(5.2)
    color: "#343434"

    //Add below so we can launch other apps :)
    signal launchApplication(string appId, string appParams);
    onLaunchApplication: {
        navigationBar.__launchApplication(appId, appParams);
    }

    /////// private //////
    property QtObject __lunaNextLS2Service: LunaService {
        id: lunaNextLS2Service
        name: "org.webosports.luna"
        usePrivateBus: true
    }

    function __launchApplication(id, params) {
        console.log("launching app " + id + " with params " + params);
        lunaNextLS2Service.call("luna://com.palm.applicationManager/launch",
        JSON.stringify({"id": id, "params": params}), undefined, __handleLaunchAppError)
    }

    function __handleLaunchAppError(message) {
        console.log("Could not start application : " + message);
    }

    Image
    {
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
                    //TODO: Fix URL in addressBar
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
                    //TODO fix URL in addressBar
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

    TextField {
        id: addressBar
        anchors.left: forwardImage.right
        anchors.verticalCenter: navigationBar.verticalCenter
        width: navigationBar.width - forwardImage.width - backImage.width
               - shareImage.width - newCardImage.width - bookmarkImage.width - 20
        height: Units.gu(3.5)
        font.family: "Prelude"
        font.pixelSize: FontUtils.sizeToPixels("medium")

        style: TextFieldStyle {

            placeholderTextColor: "#e5e5e5"
            textColor: "#e5e5e5"
            background: Rectangle {

                height: parent.height
                width: parent.width
                color: "transparent"

                //This one is nasty, but to due QML limitations need to use 3 images for this.
                Image
                {
                    id: leftAddressBar
                    height: parent.height
                    width: 18
                    anchors.left: parent.left
                    source: "images/input-tool-left.png"

                }

                Image
                {
                    id: centerAddressBar
                    height: parent.height
                    width: parent.width - leftAddressBar.width - rightAddressBar.width
                    anchors.left: leftAddressBar.right
                    fillMode: Image.Stretch
                    source: "images/input-tool-center.png"

                }

                Image
                {
                    id: rightAddressBar
                    height: parent.height
                    width: 18
                    anchors.left: centerAddressBar.right
                    source: "images/input-tool-right.png"
                }
            }
        }


        /*Image {
                    id: secureSite
                                anchors.left: addressBar.left
                                            source: "images/secure-lock.png" & webView.url
                                            //visible: false
          */                                          }

        /*Image {
                    id: faviconImage
                                anchors.verticalCenter: addressBar.verticalCenter
                                            source: webView.icon
                                                    }*/
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
                anchors.fill: parent

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
                        console.log("reloading")
                        if(addressBar.text!=="")
                        {
                        pb2.height = Units.gu(1/2)
                        pb2.value = 0
                            }
                        webView.reload
                        loadingIndicator.source = "images/menu-icon-stop.png"

                    } else {
                        webView.stop
                        loadingIndicator.source = "images/menu-icon-refresh.png"
                        pb2.height = 0
                        pb2.value = 0

                    }
                }
            }
        }

        Timer {
            running: webView.loadProgress === 100
            repeat: true
            interval: 500
            onTriggered: {
                if (!webView.loading) {
                    pb2.height = 0
                    //TODO fix the addressBar text for forward and backward
                    //addressBar.text = webView.url

                }

                loadingIndicator.source = "images/menu-icon-refresh.png"
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

        anchors.margins: Units.gu(1)
        focus: true
        text: ""
        placeholderText: "Enter URL or search terms"

        onAccepted: updateURL()

        MouseArea {
                     id: selectText
                     anchors.fill: parent
                     onPressed: addressBar.selectAll()
                     //onReleased: addressBar.deselect()
                 }

        //TODO Dirty function for prefixing with http:// for now. Would be good if we can detect if site can do https and use that or else http
        function updateURL() {

            var uri = URLUtil.parseUri(addressBar.text)
            if ((URLUtil.isValidScheme(uri) && URLUtil.isUri(
                     addressBar.text,
                     uri)) /*|| (enyo.windowParams.allowAllSchemes && uri.scheme) */) {
                if (text.substring(0, 7) === "http://" || text.substring(
                            0, 8) === "https://") {
                    webView.url = addressBar.text
                    pb2.height = Units.gu(1 / 2)
                    loadingIndicator.source = "images/menu-icon-stop.png"

                } else {
                    webView.url = "http://" + addressBar.text
                    addressBar.text = "http://" + addressBar.text
                    pb2.height = Units.gu(1 / 2)
                    loadingIndicator.source = "images/menu-icon-stop.png"


                }
            } else {
                //TODO add additional options for searching
                webView.url = "https://www.google.com/search?q=" + addressBar.text
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
        opacity: .5

        MouseArea {
            anchors.fill: parent

            onPressed: {
                shareImage.verticalAlignment = Image.AlignBottom
                shareImage.opacity = 1.0
            }
            onReleased: {
                shareImage.verticalAlignment = Image.AlignTop
                shareImage.opacity = 0.5
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
                console.log("New Card Pressed")
                newCardImage.verticalAlignment = Image.AlignBottom
                navigationBar.launchApplication("org.webosports.app.browser", "{}");
            }
            onReleased: {
                console.log("New Card Released")
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
        verticalAlignment: Image.AlignTop
        opacity: .5

        MouseArea {
            anchors.fill: parent

            onPressed: {
                bookmarkImage.verticalAlignment = Image.AlignBottom
                bookmarkImage.opacity = 1.0
            }
            onReleased: {
                bookmarkImage.verticalAlignment = Image.AlignTop
                bookmarkImage.opacity = 0.5
            }
        }
    }
}

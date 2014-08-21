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
import QtTest 1.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import LunaNext.Common 0.1

Window {
    id: root
    width: 800
    height: 600

    property bool pageIsLoading: false
    property bool historyAvailable: false
    property bool forwardAvailable: false

    /* Without this line, we won't ever see the window... */
    Component.onCompleted: {
        root.visible = true

        createNewTab("http://webos-ports.org");
    }

    function createNewTab(url) {
        tabView.addTab("test", browserTab);
    }

    Connections {
        target: application // this is luna-qml-launcher C++ object instance
        onRelaunched: console.log(
                          "The browser has been relaunched with parameters: " + parameters)
    }

    TabView {
        id: tabView

        anchors.fill: parent
    }

    Component {
        id: browserTab

        Item {
            id: browserView

            anchors.fill: parent

            property string url: ""

            NavigationBar {
                id: navigationBar
                webView: webViewItem
                onNewTab: root.createNewTab("");
            }

            WebView {
                id: webViewItem
                anchors.top: pb2.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

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

                    console.log("onLoadingChanged: status=" + loadRequest.status)
                    if (loadRequest.status == WebView.LoadStartedStatus)
                        pageIsLoading = true
                    console.log("Loading started...")
                    if (loadRequest.status == WebView.LoadFailedStatus) {
                        console.log("Load failed! Error code: " + loadRequest.errorCode)
                        pageIsLoading = false
                        if (loadRequest.errorCode === NetworkReply.OperationCanceledError)
                            console.log("Load cancelled by user")
                        pageIsLoading = false
                    }
                    if (loadRequest.status == WebView.LoadSucceededStatus)
                        pageIsLoading = false

                    console.log("Page loaded!")
                }

                url: browserView.url
            }

            ProgressBar {
                id: pb2
                property int minimum: 0
                property int maximum: 100
                property int value: 0

                minimumValue: 0
                maximumValue: 100
                height: 0
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
                        color: "#2E8CF7"
                        border.color: "steelblue"
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
                        webViewBackground.source = ""
                        webViewPlaceholder.source = ""
                    }
                    //Update ProgressBar (this one is more accurate compared to legacy :))
                    pb2.value = webViewItem.loadProgress
                }
            }
        }
    }
}

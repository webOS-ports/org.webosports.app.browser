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
import QtQuick.Window 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import LunaNext.Common 0.1
import LuneOS.Service 1.0
import LuneOS.Application 1.0 as LuneOS
import "Utils"
import "js/util.js" as EnyoUtils

LuneOS.ApplicationWindow {
    id: window

    type: LuneOS.ApplicationWindow.Card

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
                privateByDefault = true;
            } else {
                privateByDefault = false;
            }
            if (enableDebugOutput) {
                console.log("privateByDefault: " + privateByDefault);
            }
        }
    }

    /////// private //////
    LunaService {
        id: luna
        name: "org.webosports.app.browser"
    }

    function __launchApplication(id, params) {
        console.log("launching app " + id + " with params " + params.toString());
        luna.call("luna://com.palm.applicationManager/launch", JSON.stringify({
                                                                                  id: id,
                                                                                  params: params
                                                                              }),
                  undefined, __handleLaunchAppError);
    }


    function __handleLaunchAppError(message) {
        console.log("Could not start application : " + message);
    }

    function __queryDB(action, params) {
        luna.call("luna://com.palm.db/" + action, params,
                  __handleQueryDBSuccess, __handleQueryDBError);
    }

    function __handleQueryDBError(message) {
        console.log("Could not query DB : " + message);
    }

    function __handleQueryDBSuccess(message) {
        console.log("Handle DB Query Success: "+JSON.stringify(message.payload));
        if (dataMode === "bookmarks") {
            myBookMarkData = message.payload;
        } else if (dataMode === "downloads") {
            myDownloadsData = '{"results":[{"url":"Downloads not implemented yet", "title":"Downloads not implemented yet"}]}';
        } else if (dataMode === "history") {
            myHistoryData = message.payload;
        }
        else
        {
            console.log("Handle DB Query Success: "+JSON.stringify(message.payload));
        }
    }

    function __queryPutDB(myData) {
        if (enableDebugOutput) {
            console.log("Putting Data to DB (main.qml): JSON.stringify(myData): " + JSON.stringify(
                            myData));
        }
        luna.call("luna://com.palm.db/put", JSON.stringify({
                                                               objects: [myData]
                                                           }),
                  __handlePutDBSuccess, __handlePutDBError);
    }

    function __handlePutDBError(message) {
            console.log("Could not put DB : " + message);
    }

    function __handlePutDBSuccess(message) {
        if(enableDebugOutput)
        {
            console.log("Put DB: " + JSON.stringify(message.payload));
        }
    }

    function __getConnectionStatus()
    {
        luna.call("luna://com.palm.connectionmanager/getstatus", JSON.stringify({}),
                                        __connectionStatusSuccess, __connectionStatusError);
    }

    function __connectionStatusSuccess(message)
    {
        connectionStatus = JSON.parse(message.payload);
        internetAvailable = connectionStatus.isInternetConnectionAvailable;
        if(enableDebugOutput)
        {
            console.log("Internet Available: " + internetAvailable);
        }

    }

    function __connectionStatusError(message)
    {
        console.log("Unable to get connection status");
    }

    property real keyboardHeight: Qt.inputMethod.keyboardRectangle.height
    property bool pageIsLoading: false
    property bool historyAvailable: false
    property bool forwardAvailable: false
    property bool enableDebugOutput: true
    property string myBookMarkData: '{}'
    property string myDownloadsData: '{}'
    property string myHistoryData: '{}'
    property string dataMode: "bookmarks"
    property bool privateByDefault: false
    property var connectionStatus
    property bool internetAvailable: false
    property alias url: webViewItem.url
    property Item windowManager: null

    function activateAppMenu() {
        appMenu.visible = !appMenu.visible;
    }

    /* Without this line, we won't ever see the window... */
    Component.onCompleted:
    {
        window.show()
        window.visible = true

        //Determine initial connection status
        __getConnectionStatus()

        //Run query so we have the bookmarks item on first load of the panel
        window.__queryDB(
                    "find",
                    '{"query":{"from":"com.palm.browserbookmarks:1", "limit":32}}')

        var lparams = JSON.parse(application.launchParameters)
        if (lparams.target && lparams.target.length > 0)
        {
            if (lparams.target.substring(0,7)==="http://" || lparams.target.substring(0,8)==="https://" || lparams.target.substring(0,6)==="ftp://" || lparams.target.substring(0,7)==="data://" || lparams.target.substring(0,6)==="about:")
            {
                webViewItem.url = lparams.target
            }
            else
            {
                //We require http(s) for the URLs to load, so add http for now when it's not available
                webViewItem.url = "http://"+lparams.target
            }
        }
    }

    AppMenu {
        id: appMenu
        z: 100 // above everything in the app
        visible: false
        anchors.fill: parent

        onSettingsMenuItem:
        {
            settingsPage.showPage()
        }
    }

    SettingsPage {
        z: 4
        id: settingsPage
        anchors.fill: parent
        visible: false


    }

    NavigationBar {
        id: navigationBar
        webView: webViewItem
        z: 2

    }

    WebView
    {
        id: webViewItem
    }

    ShareOptionList
    {
        id: shareOptionsList
    }

    MyProgressBar
    {
        id: progressBar
    }

    BookmarkDialog {
        id: bookmarkDialog
    }

    Rectangle {
           id: dimBackground
           width: parent.width
           height: parent.height
           color: "#4C4C4C"
           visible: false
           opacity: 0.9
           z:3

           MouseArea { anchors.fill: parent; }
       }

    SidePanel
    {
        id: sidePanel
    }

    }

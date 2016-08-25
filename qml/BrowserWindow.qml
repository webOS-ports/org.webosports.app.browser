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
import LuneOS.Application 1.0
import LuneOS.Components 1.0
import "js/util.js" as EnyoUtils

import "AppTweaks"

LuneOSWindow {
    id: appWindow

    type: LuneOSWindow.Card

    width: 1024
    height: 768

    property bool enableDebugOutput: true
    property string myBookMarkData: '{}'
    property string myDownloadsData: '{}'
    property string myHistoryData: '{}'
    property string dataMode: "bookmarks"
    property var connectionStatus
    readonly property bool internetAvailable: connectionStatus ? connectionStatus.isInternetConnectionAvailable : false
    property alias url: webViewItem.url
    property Item windowManager

    UserAgent {
        id: userAgent
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
        if(enableDebugOutput)
        {
            console.log("Internet Available: " + internetAvailable);
        }

    }

    function __connectionStatusError(message)
    {
        console.log("Unable to get connection status");
    }

    function activateAppMenu() {
        appMenu.visible = !appMenu.visible;
    }

    function openNewCard(url) {
        appWindow.__launchApplication( "org.webosports.app.browser",
                                    JSON.stringify({"target": url})  );
    }

    function setClipboard(url) {
        browserClipboard.copyToClipboard(url);
    }

    Component.onCompleted:
    {
        /* Without this line, we won't ever see the window... */
        appWindow.show()
        appWindow.visible = true

        //Determine initial connection status
        __getConnectionStatus()

        //Run query so we have the bookmarks item on first load of the panel
        appWindow.__queryDB(
                    "find",
                    '{"query":{"from":"com.palm.browserbookmarks:1", "limit":32}}')
    }

    states: [
               State {
                   name: "browsing"
                   StateChangeScript {
                       script: windowDlgHelper.hideCurrentDialog();
                   }
               },
                State {
                    name: "shareOptions"
                    StateChangeScript {
                        script: windowDlgHelper.showDialog(shareOptionsList, 0);
                    }
                },
                State {
                    name: "bookmarkDialog"
                    StateChangeScript {
                        script: windowDlgHelper.showDialog(bookmarkDialog, 0.9);
                    }
                },
                State {
                    name: "historyPanel"
                    StateChangeScript {
                        script: windowDlgHelper.showDialog(historyPanel, 0);
                    }
                }
           ]

    Clipboard {
        id: browserClipboard
    }

    NavigationBar {
        id: navigationBar
        z: 2 // place it above the webview, so that the copy/cut/paste items are visible over the webview

        webView: webViewItem

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: webViewItem.isFullScreen ? 0 : Units.gu(5.2)

        onToggleShareOptionsList: {
            if(appWindow.state !== "shareOptions") {
                appWindow.state = "shareOptions";
            }
            else {
                appWindow.state = "browsing";
            }
        }
        onToggleHistoryPanel: {
            if(appWindow.state !== "historyPanel") {
                appWindow.state = "historyPanel";
            }
            else {
                appWindow.state = "browsing";
            }
        }
    }

    BrowserWebView
    {
        id: webViewItem
        z: 1
        anchors.top: navigationBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    //Disable the ScrollIndicator since QtWebView already offers scrollbars out of the box
    /*
    ScrollIndicator {
        flickableItem: webViewItem
        z: (webViewItem.z + navigationBar.z)/2
    }*/

    DialogHelper {
        // the purpose of this item is simply to catch mouse clicks outside of the
        // eventually currently shown dialog/panel.
        id: windowDlgHelper
        anchors.fill: parent
        z: 2

        onDialogHidden: appWindow.state = "browsing";
    }

    ShareOptionList
    {
        id: shareOptionsList
        anchors.top: navigationBar.bottom
        anchors.right: parent.right
        anchors.rightMargin: Units.gu(2)

        onShowBookmarkDialog: {
            bookmarkDialog.action = action;
            bookmarkDialog.myURL = "" + webViewItem.url;
            bookmarkDialog.myTitle = webViewItem.title;
            bookmarkDialog.myButtonText = buttonText;

            appWindow.state = "bookmarkDialog";
        }
    }

    BookmarkDialog {
        id: bookmarkDialog
        anchors.centerIn: parent
        anchors.verticalCenterOffset : -Qt.inputMethod.keyboardRectangle.height/2.

        mainAppWindow: appWindow

        z: 2
    }

    HistoryPanel
    {
        id: historyPanel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        z: 2
    }

    ContextMenu
    {
        id: contextMenu
        z: 3
    }

    SettingsPage {
        z: 4
        id: settingsPage
        anchors.fill: parent
        visible: false
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
}

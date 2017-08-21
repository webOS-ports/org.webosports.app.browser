/*
* Copyright (C) 2014 Simon Busch <morphis@gravedo.de>
* Copyright (C) 2014-2016 Herman van Hazendonk <github.com@herrie.org>
* Copyright (C) 2014-2016 Christophe Chapuis <chris.chapuis@gmail.com>
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

import QtQuick.Controls 2.0

import LunaNext.Common 0.1
import LuneOS.Service 1.0
import LuneOS.Application 1.0
import LuneOS.Components 1.0

import "AppTweaks"
import "Settings"
import "Utils"
import "Models"
import "js/util-sharing.js" as SharingUtils

ApplicationWindow {
    id: appWindow

    width: 1024
    height: 768

    signal openNewCardForRequest(var request);

    property bool enableDebugOutput: true
    property var connectionStatus
    readonly property bool internetAvailable: connectionStatus ? connectionStatus.isInternetConnectionAvailable : false
    property alias url: webViewItem.url
    property alias internalWebView: webViewItem
    property Item windowManager

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

    function __subscribeConnectionStatus()
    {
        luna.call("luna://com.palm.connectionmanager/getstatus", JSON.stringify({"subscribe": true}),
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
        __subscribeConnectionStatus()
    }


    Clipboard {
        id: browserClipboard
    }

    HistoryDbModel {
        id: mainHistoryDbModel
    }

    BookmarkDbModel {
        id: mainBookmarkDbModel
    }

    DownloadsDbModel {
        id: mainDownloadsDbModel
    }

    NavigationBar {
        id: navigationBar
        z: 2 // place it above the webview, so that the copy/cut/paste items are visible over the webview

        webView: webViewItem
        historyDbModel: mainHistoryDbModel

        y: webViewItem.isFullScreen ? -height : 0
        anchors.left: parent.left
        anchors.right: parent.right
        height: Units.gu(5.2)

        onLaunchApplication: appWindow.__launchApplication(id, params);
        onToggleShareOptionsList: shareOptionsList.open();
        onToggleSidePanel: {
            if(sidePanel.visible)
                sidePanel.close();
            else
                sidePanel.open();
        }

        Behavior on y {
            NumberAnimation { duration: 300 }
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

        internetAvailable: appWindow.internetAvailable
        historyDbModel: mainHistoryDbModel

        onOpenNewCardForRequest: appWindow.openNewCardForRequest(request);
        onOpenNewCard: appWindow.openNewCard(urlToOpen);
        onOpenContextualMenu: contextMenu.show();
    }

    //Disable the ScrollIndicator since QtWebView already offers scrollbars out of the box
    /*
    ScrollIndicator {
        flickableItem: webViewItem
        z: (webViewItem.z + navigationBar.z)/2
    }*/

    ShareOptionList
    {
        id: shareOptionsList
        y: navigationBar.y+navigationBar.height
        x: parent.width-width
        rightMargin: Units.gu(2)

        onShowBookmarkDialog: {
            bookmarkDialog.action = action;
            bookmarkDialog.myURL = "" + webViewItem.url;
            bookmarkDialog.myTitle = webViewItem.title;
            bookmarkDialog.myButtonText = buttonText;

            bookmarkDialog.open();
        }
    }

    BookmarkDialog {
        id: bookmarkDialog

        x: parent.width/2-width/2
        y: parent.height/2-height/2

        width: Math.min(Units.gu(46), appWindow.width-Units.gu(2));

        bookmarksDbModel: mainBookmarkDbModel
    }

    SidePanel
    {
        id: sidePanel

        edge: Qt.RightEdge
        height: parent.height
        width: appWindow.width < 900 ? parent.width : Units.gu(32)

        historyDbModel: mainHistoryDbModel
        bookmarksDbModel: mainBookmarkDbModel
        downloadsDbModel: mainDownloadsDbModel

        onGoToURL: webViewItem.url = url;

        onAddBookmark: {
            bookmarkDialog.action = "addBookmark"
            bookmarkDialog.myURL = "" + webViewItem.url
            bookmarkDialog.myTitle = webViewItem.title
            bookmarkDialog.myButtonText = "Add Bookmark"

            bookmarkDialog.open();
        }
        onEditBookmark:  {
            bookmarkDialog.action = "editBookmark";
            bookmarkDialog.myURL = "" + url;
            bookmarkDialog.myTitle = title
            bookmarkDialog.myBookMarkIcon = icon
            bookmarkDialog.myBookMarkId = id
            bookmarkDialog.myButtonText = "Save"

            bookmarkDialog.open();
        }
    }

    SettingsPage {
        z: 4
        id: settingsPage
        anchors.fill: parent
        visible: false

        historyDbModel: mainHistoryDbModel
        bookmarkDbModel: mainBookmarkDbModel
        defaultSearchProviderDisplayName: navigationBar.defaultSearchDisplayName

        onApplyNewPreferences: {
            navigationBar.defaultSearchURL = defaultSearchURL;
            navigationBar.defaultSearchIcon = defaultSearchIcon;
            navigationBar.defaultSearchDisplayName = defaultSearchDisplayName;
            webViewItem.settings.javascriptEnabled = enableJavascript;
            webViewItem.settings.javascriptCanOpenWindows = !blockPopups;
            webViewItem.settings.pluginsEnabled = enablePlugins;
            webViewItem.profile.persistentCookiesPolicy = acceptCookies ? "AllowPersistentCookies" : "NoPersistentCookies"
            webViewItem.profile.offTheRecord = acceptCookies ? false : true
        }
    }

    AppMenu {
        id: appMenu
        visible: false
        x: 0; y: 0

        onSettingsMenuItem:
        {
            settingsPage.showPage()
        }
    }
}

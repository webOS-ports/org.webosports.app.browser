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

import "AppTweaks"
import "Settings"
import "Utils"
import "Models"
import "js/util-sharing.js" as SharingUtils

LuneOSWindow {
    id: appWindow

    type: LuneOSWindow.Card

    width: 1024
    height: 768

    property bool enableDebugOutput: true
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

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: webViewItem.isFullScreen ? 0 : Units.gu(5.2)

        onLaunchApplication: appWindow.__launchApplication(id, params);
        onToggleShareOptionsList: windowDlgHelper.toggleDialog(shareOptionsList, false);
        onToggleSidePanel: windowDlgHelper.toggleDialog(sidePanel, false);
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

        onOpenNewCard: appWindow.openNewCard(urlToOpen);
        onOpenContextualMenu: contextMenu.show();
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

        onDialogHidden: windowDlgHelper.hideCurrentDialog();
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

            windowDlgHelper.showDialog(bookmarkDialog, true);
        }
    }

    BookmarkDialog {
        id: bookmarkDialog
        anchors.centerIn: parent
        anchors.verticalCenterOffset : -Qt.inputMethod.keyboardRectangle.height/2.
        z: 2

        bookmarksDbModel: mainBookmarkDbModel
    }

    SidePanel
    {
        id: sidePanel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: Screen.width < 900 ? parent.width : Units.gu(32)
        z: 2

        historyDbModel: mainHistoryDbModel
        bookmarksDbModel: mainBookmarkDbModel
        downloadsDbModel: mainDownloadsDbModel

        onGoToURL: webViewItem.url = url;

        onAddBookmark: {
            bookmarkDialog.action = "addBookmark"
            bookmarkDialog.myURL = "" + webViewItem.url
            bookmarkDialog.myTitle = webViewItem.title
            bookmarkDialog.myButtonText = "Add Bookmark"

            windowDlgHelper.showDialog(bookmarkDialog, true);
        }
        onEditBookmark:  {
            bookmarkDialog.action = "editBookmark";
            bookmarkDialog.myURL = "" + url;
            bookmarkDialog.myTitle = title
            bookmarkDialog.myBookMarkIcon = icon
            bookmarkDialog.myBookMarkId = id
            bookmarkDialog.myButtonText = "Save"

            windowDlgHelper.showDialog(bookmarkDialog, true);
        }
    }

    ContextMenu
    {
        id: contextMenu
        z: 3

        onOpenNewCard: {
            windowDlgHelper.hideCurrentDialog();
            appWindow.openNewCard(url)
        }

        onShareLinkViaEmail: {
            windowDlgHelper.hideCurrentDialog();
            SharingUtils.shareLinkViaEmail(url, contextMenu.contextText)
        }

        onCopyURL: {
            windowDlgHelper.hideCurrentDialog();
            appWindow.setClipboard(url)
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
}

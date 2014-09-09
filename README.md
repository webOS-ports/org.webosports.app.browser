Universe Navigator
==================

Next generation Universe web browser.

Summary
-------
The Universe web navigator, which will be the default web browser for the webOS ports project.

Description
-----------
The Universe web navigator is built completely in QML on top of Qt WebKit and enables the user to browse the web.

Features
-----------
Features:

1. Loads pages.
2. Creates browser history.
3. Private browsing feature via Tweaks (doesn't create history).
4. Ability to add boookmarks.
5. Can go back and forward.
6. URL prediction based on browser history.
7. UI similar to legacy 3.0.x browser.
8. Support for both tablet (landscape) and phone (portrait) layout.

Known bugs
-----------
Known bugs:

1. After closing bookmarks/history/downloads panel, tapping on URL bar doesn't bring up Virtual Keyboard.
2. URL suggestions only looks in browser history, not in bookmarks yet.
3. Bookmarks panel is empty on loading.
4. Search doesn't always work yet.
5. Various layout and rendering issues.
6. Page gets added to browser history, even when not loaded (for example when there's no network connectivity).
7. Progress bar doesn't always behave properly.
8. Share dialog not working yet.

To do:
-----------
To do:

1. Add FocusScope to addressBar to see if that solves the VKB focus issue.
2. Fix the creation of browsing history for only properly loaded pages.
3. Add bookmarks in URL suggestions as well.
4. Create settings page to replicate settings from legacy.
5. Add additional browser Tweaks (look at legacy to see what's interesting). 
6. Add launch parameters + handling
7. Add icons for bookmarks (investigate legacy's handling). 
8. Add "search in page"
9. Add select, copy & paste where possible
10. Fix share dialog

## Contributing

If you want to contribute you can just start with cloning the repository and make your
contributions. We're using a pull-request based development and utilizing github for the
management of those. All developers must provide their contributions as pull-request and
github and at least one of the core developers needs to approve the pull-request before it
can be merged.

Please refer to http://www.webos-ports.org/wiki/Communications for information about how to
contact the developers of this project.


org.webosports.app.phone
========================

Summary
-------
The webOS ports browser application.

Description
-----------
This is the default browser of the webOS ports distribution. It's based on Qt and QML and
is using webkit as rendering engine.

How to Build on Linux
=====================

## Dependencies

Below are the tools and libraries (and their minimum versions) required to build
telephonyd:

* cmake (version required by openwebos/cmake-modules-webos)
* gcc 4.6.3
* glib-2.0 2.32.1
* qt 4.8
* make (any version)

## Building

Once you have downloaded the source, enter the following to build it (after
changing into the directory under which it was downloaded):

    $ qmake
    $ make
    $ sudo make install

# Copyright and License Information

Unless otherwise specified, all content, including all source code files and
documentation files in this repository are:

Copyright (c) 2013 Simon Busch <morphis@gravedo.de>

This application is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 3.

telephony-app is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

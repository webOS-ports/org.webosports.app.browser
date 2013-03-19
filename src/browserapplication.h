/*
 * Copyright (C) 2013 Simon Busch <morphis@gravedo.de>
 *
 * This file is part of the org.webosports.app.phone application.
 *
 * This application is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * telephony-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef TELEPHONYAPPLICATION_H_
#define TELEPHONYAPPLICATION_H_

#include <QApplication>
#include <QGLWidget>
#include <QDeclarativeView>

class BrowserApplication : public QApplication
{
	Q_OBJECT
public:
	explicit BrowserApplication(int &argc, char **argv);
	~BrowserApplication();

private:
	QGLWidget *_widget;
	QDeclarativeView *_view;
};

#endif
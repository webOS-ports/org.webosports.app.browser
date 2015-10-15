/*
 * Copyright (C) 2013 Simon Busch <morphis@gravedo.de>
 * Copyright (C) 2014 Nikolay Nizov <nizovn@gmail.com>
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

#include <QtQml>

#include "plugin.h"
#include "browserutils.h"

BrowserUtilsPlugin::BrowserUtilsPlugin(QObject *parent) :
	QQmlExtensionPlugin(parent)
{
}

void BrowserUtilsPlugin::registerTypes(const char *uri)
{
	Q_ASSERT(uri == QLatin1String("browserutils"));
	qmlRegisterType<BrowserUtils>(uri, 0, 1, "BrowserUtils");
}

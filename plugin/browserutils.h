/*
 * Copyright 2013 Canonical Ltd.
 *
 * This file is part of webbrowser-app.
 *
 * webbrowser-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * webbrowser-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef __BROWSERUTILS_H__
#define __BROWSERUTILS_H__

// Qt
#include <QtCore/QSize>
#include <QtCore/QUrl>
#include <QQuickItem>
#include <QtQuick/private/qquickitem_p.h>

class QQuickWebEngineView;

class BrowserUtils : public QQuickItem
{
	Q_OBJECT

	Q_PROPERTY(QQuickWebEngineView* webview READ webview WRITE setWebview NOTIFY webviewChanged)

public:
	BrowserUtils(QQuickItem* parent=0);

	QQuickWebEngineView* webview() const;
	void setWebview(QQuickWebEngineView* webview);

	Q_INVOKABLE void saveViewToFile(const QString outFile, const QSize imageSize);
	Q_INVOKABLE void generateIconFromFile(const QString inFile, const QString outFile, const QSize imageSize);

Q_SIGNALS:
	void webviewChanged() const;
	void webViewSaved(bool success, QString fileName) const;
	void iconGenerated(bool success, QString fileName) const;

protected:
	virtual QSGNode* updatePaintNode(QSGNode* oldNode, UpdatePaintNodeData* updatePaintNodeData);

private Q_SLOTS:
	void doSaveWebView();

private:
	QQuickWebEngineView* m_webview;
	QString m_outFile;
	QSize m_imageSize;
};
#endif // __BROWSERUTILS_H__

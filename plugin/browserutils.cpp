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

#include "browserutils.h"

// Qt
#include <QtCore/QtGlobal>
#include <QtCore/QMetaObject>
#include <QtCore/QTimer>
#include <QtQuick/private/qsgrenderer_p.h>
#include <QtWebKit/private/qquickwebpage_p.h>
#include <QtWebKit/private/qquickwebview_p.h>
#include <QDateTime>
#include <QImage>
#include <QStandardPaths>
#include <QDir>

const char* kIconMaskFile = "/usr/palm/applications/org.webosports.app.browser/qml/images/launcher-bookmark-alpha.png";
const char* kIconOverlayFile = "/usr/palm/applications/org.webosports.app.browser/qml/images/launcher-bookmark-overlay.png";

class BindableFbo : public QSGBindable
{
public:
	BindableFbo(QOpenGLFramebufferObject* fbo) : m_fbo(fbo) {}
	virtual void bind() const { m_fbo->bind(); }

private:
	QOpenGLFramebufferObject *m_fbo;
};

BrowserUtils::BrowserUtils(QQuickItem* parent)
	: QQuickItem(parent)
	, m_webview(0)
{
}

QQuickWebView* BrowserUtils::webview() const
{
	return m_webview;
}

void BrowserUtils::setWebview(QQuickWebView* webview)
{
	if (webview != m_webview) {
		m_webview = webview;
		setFlag(QQuickItem::ItemHasContents, false);
		Q_EMIT webviewChanged();
	}
}

void BrowserUtils::saveViewToFile(const QString outFile, const QSize imageSize)
{
	m_outFile = outFile;
	m_imageSize = imageSize;
	// Delay the actual rendering to give all elements on the page
	// a chance to be fully rendered.
	QTimer::singleShot(1000, this, SLOT(doSaveWebView()));
}

void BrowserUtils::generateIconFromFile(const QString inFile, const QString outFile, const QSize imageSize)
{
	QImage inImage(inFile);
	if (inImage.isNull()) {
		qWarning() << "generateIconFromFile - failed to open source file";
		Q_EMIT iconGenerated(false, outFile);
		return;
	}
	const int nMargin = 4;// Must agree with pixel data in image files
	const int nIconSize = 64;// Width & height of output image
	const int nIconWidth = nIconSize-2*nMargin;// Width of icon image within file
	const int nIconHeight = nIconSize-2*nMargin;
	QImage outImage(nIconSize, nIconSize, QImage::Format_ARGB32_Premultiplied);
	outImage.fill(0);
	QPainter painter(&outImage);
	painter.setRenderHint(QPainter::SmoothPixmapTransform);
	QRectF source(0.0, 0.0, imageSize.width(), imageSize.height());
	QRectF target(nMargin, nMargin, nIconWidth, nIconHeight);
	QRectF size(0.0, 0.0, nIconSize, nIconSize);
	painter.setCompositionMode(QPainter::CompositionMode_SourceOver);
	painter.drawImage(target, inImage, source);
	painter.setCompositionMode(QPainter::CompositionMode_DestinationIn);
	QImage maskImage(kIconMaskFile);
	painter.drawImage(target, maskImage, target);
	painter.setCompositionMode(QPainter::CompositionMode_SourceOver);
	QImage overlayImage(kIconOverlayFile);
	painter.drawImage(size, overlayImage, size);

	QFileInfo imageInfo(outFile);
	QDir imageDir(imageInfo.path());
	if (!imageDir.exists()) {
		imageDir.mkpath(".");
	}

	bool saved = outImage.save(outFile);
	Q_EMIT iconGenerated(saved, outFile);
}

void BrowserUtils::doSaveWebView()
{
	if (m_webview) {
		setFlag(QQuickItem::ItemHasContents);
		update();
	}
}

QSGNode* BrowserUtils::updatePaintNode(QSGNode* oldNode, UpdatePaintNodeData* updatePaintNodeData)
{
	Q_UNUSED(updatePaintNodeData);

	if (!(m_webview && (flags() & QQuickItem::ItemHasContents))) {
		return oldNode;
	}
	setFlag(QQuickItem::ItemHasContents, false);
	QQuickWebPage* page = m_webview->page();
	qreal xmin = qMin(page->width(), m_webview->width());
	qreal ymin = qMin(m_webview->height(), page->height());
	ymin = qMin(static_cast<int>(ymin), m_imageSize.height());
	xmin = qMin(static_cast<int>(xmin), m_imageSize.width());

	QSize size(xmin, ymin);

	QSGNode* node = QQuickItemPrivate::get(page)->itemNode();
	QSGNode* parent = node->QSGNode::parent();
	QSGNode* previousSibling = node->previousSibling();
	if (parent) {
		parent->removeChildNode(node);
	}
	QSGRootNode root;
	root.appendChildNode(node);

	QSGRenderer* renderer;
#if QT_VERSION < QT_VERSION_CHECK(5, 2, 0)
	renderer = QQuickItemPrivate::get(this)->sceneGraphContext()->createRenderer();
#else
	renderer = QQuickItemPrivate::get(this)->sceneGraphRenderContext()->createRenderer();
#endif
	renderer->setRootNode(static_cast<QSGRootNode*>(&root));

	QOpenGLFramebufferObject fbo(size);

	renderer->setDeviceRect(size);
	renderer->setViewportRect(size);
	renderer->setProjectionMatrixToRect(QRectF(QPointF(), size));
	renderer->setClearColor(Qt::transparent);

	renderer->renderScene(BindableFbo(&fbo));

	fbo.release();

	QImage image = fbo.toImage().scaled(m_imageSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
	QFileInfo imageInfo(m_outFile);
	QDir imageDir(imageInfo.path());
	if (!imageDir.exists()) {
		imageDir.mkpath(".");
	}

	bool saved = image.save(m_outFile);

	root.removeChildNode(node);
	renderer->setRootNode(0);
	delete renderer;

	if (parent) {
		if (previousSibling) {
			parent->insertChildNodeAfter(node, previousSibling);
		} else {
			parent->prependChildNode(node);
		}
	}

	Q_EMIT webViewSaved(saved, m_outFile);

	return oldNode;
}

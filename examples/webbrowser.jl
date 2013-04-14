## using QtWebKit

using PySide

w = Qt.QWidget()
lyt = Qt.QVBoxLayout(w)
w[:setLayout](lyt)

view = QtWebKit.QWebView(w)
view[:load](QtCore.QUrl("http://www.yahoo.com/"))
lyt[:addWidget](view)

raise(w)

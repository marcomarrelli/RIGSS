from PyQt5.QtCore import QObject, QUrl, pyqtSignal
from PyQt5.QtNetwork import QNetworkAccessManager, QNetworkRequest, QNetworkReply

class NetworkChecker(QObject):
    connectionChanged = pyqtSignal(bool)

    def __init__(self, parent: QObject=None) -> None:
        super().__init__()
        self.manager = QNetworkAccessManager()
        self.manager.finished.connect(self.onFinished)

    def checkConnection(self):
        request = QNetworkRequest(QUrl("http://www.google.com"))
        self.manager.get(request)

    def onFinished(self, reply):
        if reply.error() == QNetworkReply.NetworkError.NoError:
            self.connectionChanged.emit(True)
        else:
            self.connectionChanged.emit(False)
        reply.deleteLater()

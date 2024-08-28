from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, pyqtSlot
from PyQt5.QtSql import QSqlQuery

from .baseModel import BaseModel

class ReviewsModel(BaseModel):
    def __init__(self, parent: QObject = None) -> None:
        super(ReviewsModel, self).__init__(["idValutazione", "idImpianto", "idUtente", "stelle", "recensione"])
        super().setQuery("""
            SELECT idValutazione, idImpianto, idUtente, stelle, recensione
            FROM Valutazione;
        """)

class Reviews(QObject):
    modelChanged = pyqtSignal(QObject)
    ownModelChanged = pyqtSignal(QObject)

    def __init__(self, parent: QObject=None) -> None:
        super().__init__(parent)
        
        self._model = ReviewsModel()
        self._ownModel = ReviewsModel()

    @pyqtProperty(QObject, notify=modelChanged)
    def model(self) -> ReviewsModel:
        return self._model

    @pyqtSlot()
    def refresh(self) -> None:
        self._model.setQuery(f"""
            SELECT idValutazione, idImpianto, idUtente, stelle, recensione
            FROM Valutazione;
        """)

    @pyqtSlot(int, str, result=bool)
    def canAddReview(self, idImpianto: int, idUtente: str) -> bool:
        query = QSqlQuery()
        query.prepare("SELECT COUNT(*) FROM Valutazione WHERE idImpianto = :idImpianto AND idUtente = :idUtente")
        query.bindValue(":idImpianto", idImpianto)
        query.bindValue(":idUtente", idUtente)
        if query.exec_() and query.next():
            return query.value(0) == 0
        return False

    @pyqtSlot(int, str, result=bool)
    def isReviewOwner(self, idValutazione: int, idUtente: str) -> bool:
        query = QSqlQuery()
        query.prepare("SELECT idUtente FROM Valutazione WHERE idValutazione = :idValutazione")
        query.bindValue(":idValutazione", idValutazione)
        if query.exec_() and query.next():
            return query.value(0) == idUtente
        return False

    @pyqtSlot(int, str, int, str, result=bool)
    def addReview(self, idImpianto: int, idUtente: str, stars: int = 0, review: str = "") -> bool:
        if not self.canAddReview(idImpianto, idUtente):
            return False
        query = QSqlQuery()
        query.prepare("INSERT INTO Valutazione (idImpianto, idUtente, stelle, recensione) VALUES (:idImpianto, :idUtente, :stelle, :recensione)")
        query.bindValue(":idImpianto", idImpianto)
        query.bindValue(":idUtente", idUtente)
        query.bindValue(":recensione", review)
        query.bindValue(":stelle", stars)
        if query.exec_():
            self.refresh()
            return True
        return False

    @pyqtSlot(int, str, result=bool)
    def deleteReview(self, idValutazione: int, idUtente: str) -> bool:
        if not self.isReviewOwner(idValutazione, idUtente):
            return False
        query = QSqlQuery()
        query.prepare("DELETE FROM Valutazione WHERE idValutazione = :idValutazione")
        query.bindValue(":idValutazione", idValutazione)
        if query.exec_():
            self.refresh()
            return True
        return False

    @pyqtSlot(int, result=QObject)
    def getGasStationReviews(self, idImpianto: int) -> QObject:
        query = QSqlQuery()
        q = """
            SELECT idValutazione, idImpianto, idUtente, stelle, recensione
            FROM Valutazione
            WHERE idImpianto = :idImpianto;
        """

        query.prepare(q)
        query.bindValue(":idImpianto", idImpianto)

        if query.exec_():
            self._ownModel.setQuery(query)
            return self._ownModel
        
        return QObject()

    @pyqtSlot(int, result=int)
    def getAverageRating(self, idImpianto: int) -> int:
        query = QSqlQuery()
        query.prepare("SELECT AVG(Valutazione.stelle) FROM Valutazione WHERE idImpianto = :idImpianto")
        query.bindValue(":idImpianto", idImpianto)
        
        if not query.exec_(): return 0
        if not query.next(): return 0
        
        avgR = query.value(0)

        if not avgR: return 0
        else: return int(avgR)

from PyQt5.QtCore import QObject, pyqtSlot, pyqtSignal, QDateTime
from PyQt5.QtSql import QSqlQuery

from .baseModel import BaseModel

class TransactionsModel(BaseModel):
    def __init__(self, parent: QObject = None) -> None:
        super(TransactionsModel, self).__init__(["idTransazione", "idImpianto", "idUtente", "metodoPagamento", "tipologia", "servito", "quantita", "spesa", "dataTransazione"])
        super().setQuery("""
            SELECT idTransazione, idImpianto, idUtente, metodoPagamento, tipologia, servito, quantita, spesa, dataTransazione
            FROM Transazione;
        """)

class Transactions(QObject):
    modelChanged = pyqtSignal()

    def __init__(self, parent: QObject=None) -> None:
        super().__init__(parent)
        
        self._model = TransactionsModel()

    @pyqtSlot(int, str, int, str, bool, float, float, result=bool)
    def executeTransaction(self, idImpianto, idUtente, paymentMethod, type, selfService, quantity, spent) -> bool:
        query = QSqlQuery()
        query.prepare("""
            INSERT INTO Transazione (idImpianto, idUtente, metodoPagamento, tipologia, servito, quantita, spesa, dataTransazione)
            VALUES (:idImpianto, :idUtente, :paymentMethod, :type, :selfService, :quantity, :spent, CURRENT_TIMESTAMP)
        """)
        
        query.bindValue(":idImpianto", idImpianto)
        query.bindValue(":idUtente", idUtente)
        query.bindValue(":paymentMethod", paymentMethod)
        query.bindValue(":type", type)
        query.bindValue(":selfService", selfService)
        query.bindValue(":quantity", quantity)
        query.bindValue(":spent", spent)

        if query.exec_():
            self.modelChanged.emit()
            return self.createInvoice(query.lastInsertId(), spent)

    def createInvoice(self, idTransazione, spent) -> bool:
        query = QSqlQuery()
        query.prepare("""
            INSERT INTO Fattura (idTransazione, importo, dataEmissione)
            VALUES (:idTransazione, :spent, CURRENT_TIMESTAMP)
        """)
        query.bindValue(":idTransazione", idTransazione)
        query.bindValue(":spent", spent)
        
        return query.exec_()

    @pyqtSlot(QDateTime, QDateTime, float, float, int)
    def filterTransactions(self, startDate, endDate, minSpent, maxSpent, paymentMethod):
        filterQuery = """
            SELECT idTransazione, idImpianto, idUtente, metodoPagamento, tipologia, servito, quantita, spesa, dataTransazione
            FROM Transazione
        """

        if startDate and endDate:
            filterQuery += f"\nWHERE dataTransazione BETWEEN {startDate} AND {endDate}"

        if minSpent > 0:
            filterQuery += f"\nAND spesa >= {minSpent}"

        if maxSpent > 0:
            filterQuery += f"\nAND spesa <= {maxSpent}"

        if paymentMethod > 0:
            filterQuery += f"\nAND metodoPagamento = {paymentMethod}"

        filterQuery += ";"

        query = QSqlQuery()
        query.prepare(filterQuery)

        if query.exec_():
            self._model.setQuery(query)
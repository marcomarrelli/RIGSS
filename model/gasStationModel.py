from PyQt5.QtCore import QObject, QVariant, pyqtProperty, pyqtSignal, pyqtSlot
from PyQt5.QtSql import QSqlQuery, QSqlQueryModel

from .baseModel import BaseModel

class GasStationFilter(QObject):
    filterChanged = pyqtSignal()

    def __init__(self, parent: QObject=None) -> None:
        super().__init__(parent)
        self._name = ""
        self._availableFuels = []
        self._maxPrice = 0.0
        self._service = 2  # 1: Self, 0: Served, 2: ALL
        self._order = ""

    @pyqtProperty(str, notify=filterChanged)
    def name(self) -> str:
        return self._name

    @name.setter
    def name(self, value: str) -> None:
        if self._name != value:
            self._name = value
            self.filterChanged.emit()

    @pyqtProperty(list, notify=filterChanged)
    def availableFuels(self) -> list:
        return self._availableFuels

    @availableFuels.setter
    def availableFuels(self, fuels: list) -> None:
        if self._availableFuels != fuels:
            self._availableFuels = fuels
            self.filterChanged.emit()

    @pyqtProperty(float, notify=filterChanged)
    def maxPrice(self) -> float:
        return self._maxPrice

    @maxPrice.setter
    def maxPrice(self, value: float) -> None:
        if self._maxPrice != value:
            self._maxPrice = value
            self.filterChanged.emit()

    @pyqtProperty(int, notify=filterChanged)
    def service(self) -> int:
        return self._service

    @service.setter
    def service(self, value: int) -> None:
        if self._service != value:
            self._service = value
            self.filterChanged.emit()

    @pyqtSlot(str)
    def addAvailableFuel(self, fuel: str) -> None:
        if fuel not in self._availableFuels:
            self._availableFuels.append(fuel)
            self.filterChanged.emit()

    @pyqtSlot(str)
    def removeAvailableFuel(self, fuel: str) -> None:
        if fuel in self._availableFuels:
            self._availableFuels.remove(fuel)
            self.filterChanged.emit()

    @pyqtProperty(str, notify=filterChanged)
    def order(self) -> str:
        return self._order

    @order.setter
    def order(self, value: str) -> None:
        if self._order != value:
            self._order = value
            self.filterChanged.emit()

class GasStations(QObject):
    modelChanged = pyqtSignal(QObject)
    ownModelChanged = pyqtSignal(QObject)
    filterChanged = pyqtSignal(QObject)

    def __init__(self, parent: QObject=None) -> None:
        super().__init__(parent)
        
        self._model = GasStationsModel()
        self._ownModel = GasStationsModel()
        self._filter = GasStationFilter(self)
        self._filter.filterChanged.connect(self.refresh)
        self.filterChanged.emit(self._filter)

        self.refresh()

    @pyqtProperty(QObject, notify=modelChanged)
    def model(self):
        return self._model

    @pyqtProperty(QObject, notify=filterChanged)
    def filter(self):
        return self._filter
    
    @pyqtSlot()
    def refresh(self):
        q = """
            SELECT DISTINCT Distributore.idImpianto, gestore, bandiera, tipologia, Distributore.nome, via, cap, comune, provincia, latitudine, longitudine, simulato
            FROM Distributore
            WHERE EXISTS (
                SELECT 1
                FROM Carburante
                WHERE Carburante.idImpianto = Distributore.idImpianto
        """
        
        if self._filter.maxPrice > 0.0:
            q += f" AND Carburante.prezzo <= {self._filter.maxPrice}"

        if self._filter.availableFuels:
            fuel_conditions = " OR ".join([f"Carburante.nome = '{fuel}'" for fuel in self._filter.availableFuels])
            q += f" AND ({fuel_conditions})"

        if self._filter.service < 2:
            q += f" AND Carburante.self = {self._filter.service}"

        q += ")"

        if self._filter.name:
            q += f"""
            AND (LOWER(Distributore.nome) LIKE '%{self._filter.name.lower()}%'
            OR LOWER(Distributore.comune) LIKE '%{self._filter.name.lower()}%'
            OR LOWER(Distributore.provincia) LIKE '%{self._filter.name.lower()}%')
            """

        if self._filter.order:
             q += f" ORDER BY {self._filter.order}"

        q += ";"
        self._model.setQuery(q)

    @pyqtSlot()
    def sortAscendent(self): 
        self._filter.order = "LOWER(Distributore.nome) ASC"

    @pyqtSlot()
    def sortDescendent(self): 
        self._filter.order = "LOWER(Distributore.nome) DESC"

    @pyqtSlot(str, result=list)
    def getFuels(self, idImpianto: str) -> list:
        query = QSqlQuery()
        q = f"""
            SELECT idImpianto, nome, prezzo, self
            FROM Carburante
            WHERE Carburante.idImpianto = {idImpianto}
        """
        
        if self._filter.maxPrice > 0.0:
            q += f" AND Carburante.prezzo <= {self._filter.maxPrice}"

        if self._filter.service < 2:
            q += f" AND Carburante.self = {self._filter.service}"

        if self._filter.availableFuels:
            fuel_conditions = " OR ".join([f"Carburante.nome = '{fuel}'" for fuel in self._filter.availableFuels])
            q += f" AND ({fuel_conditions});"

        query.prepare(q)
        query.exec_()
        
        results = []
        
        while query.next():
            results.append([query.value(0), query.value(1), query.value(2), query.value(3)])
        
        return results

    @pyqtSlot(int, str, float, bool, result=bool)
    def insertFuel(self, idImpianto: int, nome: str, prezzo: float, selfService: bool) -> bool:
        query = QSqlQuery()
        query.prepare("""
            INSERT INTO Carburante (idImpianto, nome, prezzo, self, dataAggiornamento)
            VALUES (:idImpianto, :nome, :prezzo, :selfService, :dataAggiornamento);
        """)
        query.bindValue(":idImpianto", idImpianto)
        query.bindValue(":nome", nome)
        query.bindValue(":prezzo", prezzo)
        query.bindValue(":selfService", selfService)
        query.bindValue(":dataAggiornamento", None)

        if query.exec_():
            self.refresh()
            return True
        else:
            print("Error Inserting Fuel:", query.lastError().text())
            return False
        
    @pyqtSlot(int, str, float, bool, result=bool)
    def updateFuel(self, idImpianto: int, nome: str, prezzo: float, selfService: bool) -> bool:
        query = QSqlQuery()

        if prezzo == 0:
            query.prepare("""
                DELETE FROM Carburante
                WHERE idImpianto = :idImpianto AND nome = :nome AND self = :selfService;
            """)
        else:
            query.prepare("""
                UPDATE Carburante
                SET prezzo = :prezzo
                WHERE idImpianto = :idImpianto AND nome = :nome AND self = :selfService;
            """)
            query.bindValue(":prezzo", prezzo)
        
        query.bindValue(":idImpianto", idImpianto)
        query.bindValue(":nome", nome)
        query.bindValue(":selfService", selfService)

        if query.exec_():
            self.refresh()
            return True
        else:
            print("Error Updating/Deleting Fuel:", query.lastError().text())
            return False

    @pyqtSlot(str, bool, result=QObject)
    def getOwnGasStations(self, gestore: str, onlySimulated: bool = False) -> QObject:
        query = QSqlQuery()
        q = """
            SELECT idImpianto, gestore, bandiera, tipologia, nome, via, cap, comune, provincia, latitudine, longitudine, simulato
            FROM Distributore
            WHERE gestore = :gestore
        """

        if onlySimulated: q += "AND simulato = 1;"
        else: q += ";"

        query.prepare(q)
        query.bindValue(":gestore", gestore)

        if query.exec_():
            self._ownModel.setQuery(query)

        return self._ownModel
 
    @pyqtSlot(str, str, str, str, str, str, str, str, float, float, result=bool)
    def insertGasStation(self, gestore: str, bandiera: str, tipologia: str, nome: str, via: str, cap: str, comune: str, provincia: str, latitudine: float, longitudine: float) -> bool:
        query = QSqlQuery()
        query.prepare("SELECT MAX(idImpianto) FROM Distributore")
        if not query.exec_() or not query.next():
            print("Error AutoIncrementing idImpianto:", query.lastError().text())
            return False
        
        maxID = 100000 if query.value(0) < 100000 else (query.value(0)+1)

        del(query)

        query = QSqlQuery()
        query.prepare("""
            INSERT INTO Distributore (idImpianto, gestore, bandiera, tipologia, nome, via, cap, comune, provincia, latitudine, longitudine, simulato)
            VALUES (:idImpianto, :gestore, :bandiera, :tipologia, :nome, :via, :cap, :comune, :provincia, :latitudine, :longitudine, :simulato);
        """)
        
        query.bindValue(":idImpianto", maxID)
        query.bindValue(":gestore", gestore)
        query.bindValue(":bandiera", bandiera)
        query.bindValue(":tipologia", tipologia)
        query.bindValue(":nome", nome)
        query.bindValue(":via", via)
        query.bindValue(":cap", cap)
        query.bindValue(":comune", comune)
        query.bindValue(":provincia", provincia)
        query.bindValue(":latitudine", latitudine)
        query.bindValue(":longitudine", longitudine)
        query.bindValue(":simulato", True)
        
        if query.exec_():
            self.refresh()
            return True
        else:
            print("Error Inserting New Gas Station:", query.lastError().text())
            return False
    
    @pyqtSlot(int, str, str, str, str, str, str, str, str, float, float, result=bool)
    def updateGasStation(self, idImpianto: int, gestore: str, bandiera: str, tipologia: str, nome: str, via: str, cap: str, comune: str, provincia: str, latitudine: float, longitudine: float) -> bool:
        query = QSqlQuery()
        query.prepare("""
            UPDATE Distributore
            SET gestore = :gestore,
                bandiera = :bandiera,
                tipologia = :tipologia,
                nome = :nome,
                via = :via,
                cap = :cap,
                comune = :comune,
                provincia = :provincia,
                latitudine = :latitudine,
                longitudine = :longitudine
            WHERE idImpianto = :idImpianto;
        """)
        
        query.bindValue(":idImpianto", idImpianto)
        query.bindValue(":gestore", gestore)
        query.bindValue(":bandiera", bandiera)
        query.bindValue(":tipologia", tipologia)
        query.bindValue(":nome", nome)
        query.bindValue(":via", via)
        query.bindValue(":cap", cap)
        query.bindValue(":comune", comune)
        query.bindValue(":provincia", provincia)
        query.bindValue(":latitudine", latitudine)
        query.bindValue(":longitudine", longitudine)

        if query.exec_():
            self.refresh()
            return True
        else:
            print("Error Updating Gas Station:", query.lastError().text())
            return False

    @pyqtSlot(int, result=bool)
    def deleteGasStation(self, idImpianto: int) -> bool:
        query = QSqlQuery()
        query.prepare("DELETE FROM Distributore WHERE idImpianto = :idImpianto;")
        query.bindValue(":idImpianto", idImpianto)
        
        if query.exec_():
            self.refresh()
            return True
        else:
            print("Error Deleting Gas Station:", query.lastError().text())
            return False

class GasStationsModel(BaseModel):
    def __init__(self, parent: QObject = None) -> None:
        super(GasStationsModel, self).__init__(["idImpianto", "gestore", "bandiera", "tipologia", "nome", "via", "cap", "comune", "provincia", "latitudine", "longitudine", "simulato"])
        super().setQuery("""
            SELECT idImpianto, gestore, bandiera, tipologia, nome, via, cap, comune, provincia, latitudine, longitudine, simulato
            FROM Distributore;
        """)

    @pyqtSlot(str, result=str)
    def getLogo(self, bandiera: str) -> str:
        query = QSqlQuery()
        query.prepare("""
            SELECT logo
            FROM Bandiera
            WHERE Bandiera.nome = :bandiera;
        """)
        query.bindValue(":bandiera", bandiera)
        query.exec_()
        
        return query.value(0) if query.next() else ""

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, pyqtSlot
from PyQt5.QtSql import QSqlQuery

from .baseModel import BaseModel

class GasStationFilter(QObject):
    filterChanged = pyqtSignal()

    def __init__(self, parent: QObject=None) -> None:
        super().__init__(parent)
        self._name = ""
        self._availableFuels = []
        self._maxPrice = 0.0

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

class GasStations(QObject):
    modelChanged = pyqtSignal(QObject)
    filterChanged = pyqtSignal(QObject)

    def __init__(self, parent: QObject=None) -> None:
        super().__init__(parent)
        
        self._model = GasStationsModel()
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

    #@pyqtSlot()
    #def refresh(self):
    #    query_str = """
    #        SELECT DISTINCT Distributore.idImpianto, gestore, bandiera, tipologia, Distributore.nome, via, cap, comune, provincia, latitudine, longitudine, simulato
    #        FROM Distributore
    #    """
    #    
    #    if self._filter.name:
    #        query_str += f"\nWHERE LOWER(Distributore.nome) LIKE '%{self._filter.name.lower()}%'"
    #    self._model.setQuery(query_str)
    
    @pyqtSlot()
    def refresh(self):
        query_str = """
            SELECT DISTINCT Distributore.idImpianto, gestore, bandiera, tipologia, Distributore.nome, via, cap, comune, provincia, latitudine, longitudine, simulato
            FROM Distributore
            WHERE EXISTS (
                SELECT 1
                FROM Carburante
                WHERE Carburante.idImpianto = Distributore.idImpianto
        """
        
        if self._filter.maxPrice > 0.0:
            query_str += f" AND Carburante.prezzo <= {self._filter.maxPrice}"

        if self._filter.availableFuels:
            fuel_conditions = " OR ".join([f"Carburante.nome = '{fuel}'" for fuel in self._filter.availableFuels])
            query_str += f" AND ({fuel_conditions})"
        
        query_str += ")"

        if self._filter.name:
            query_str += f" AND LOWER(Distributore.nome) LIKE '%{self._filter.name.lower()}%'"

        self._model.setQuery(query_str)

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

        if self._filter.availableFuels:
            fuel_conditions = " OR ".join([f"Carburante.nome = '{fuel}'" for fuel in self._filter.availableFuels])
            q += f" AND ({fuel_conditions});"

        query.prepare(q)
        query.exec_()
        
        results = []
        
        while query.next():
            results.append([query.value(0), query.value(1), query.value(2), query.value(3)])
        
        return results

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

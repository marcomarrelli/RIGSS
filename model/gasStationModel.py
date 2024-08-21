from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, pyqtSlot
from PyQt5.QtSql import QSqlQuery

from .baseModel import BaseModel

class GasStations(QObject):
    modelChanged = pyqtSignal(QObject)
    filterChanged = pyqtSignal(str)

    def __init__(self, parent: QObject=None) -> None:
        super().__init__(parent)
        
        self._model = GasStationsModel()
        self._filter = ""
        self.filterChanged.connect(self.refresh)

    @pyqtProperty(QObject, notify=modelChanged)
    def model(self):
        return self._model

    @pyqtProperty(str, notify=filterChanged)
    def filter(self):
        return self._filter

    @filter.setter
    def filter(self, filter: str):
        self._filter = filter
        self.filterChanged.emit(filter)

    @pyqtSlot()
    def refresh(self):
        self._model.setQuery(f"""
            SELECT idImpianto, gestore, bandiera, tipologia, nome, via, cap, comune, provincia, latitudine, longitudine, simulato
            FROM Distributore
            WHERE LOWER(nome) LIKE '{self._filter}%'
            OR LOWER(comune) LIKE '{self._filter}%'
            OR LOWER(provincia) LIKE '{self._filter}%'
        """)

class GasStationsModel(BaseModel):
    def __init__(self, parent:QObject=None) -> None:
        super(GasStationsModel, self).__init__(["idImpianto", "gestore", "bandiera", "tipologia", "nome", "via", "cap", "comune", "provincia", "latitudine", "longitudine", "simulato"])
        super().setQuery("""
            SELECT idImpianto, gestore, bandiera, tipologia, nome, via, cap, comune, provincia, latitudine, longitudine, simulato
            FROM Distributore;
        """)

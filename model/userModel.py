from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, pyqtSlot
from PyQt5.QtSql import QSqlQuery

from baseModel import BaseModel

class UsersModel(BaseModel):
    def __init__(self, parent:QObject=None) -> None:
        super(UsersModel, self).__init__(["idcliente", "nome", "cognome", "codice_fiscale"])
        super().setQuery("""SELECT idcliente, nome, cognome, codice_fiscale 
                            FROM public.clienti""")
        
class Users(QObject):
    modelChanged = pyqtSignal(QObject)
    filterChanged = pyqtSignal(str)

    def __init__(self, parent: QObject=None) -> None:
        super().__init__(parent)
        
        self._model = UsersModel()
        self._filter = ""
        self.filterChanged.connect(self.refresh)

    @pyqtProperty(QObject, notify=modelChanged)
    def model(self) -> UsersModel:
        return self._model

    @pyqtProperty(str, notify=filterChanged)
    def filter(self) -> str:
        return self._filter

    @filter.setter
    def filter(self, filter: str) -> None:
        self._filter = filter
        self.filterChanged.emit(filter)

    @pyqtSlot()
    def refresh(self) -> None:
        self._model.setQuery("""SELECT idcliente, nome, cognome, codice_fiscale 
                            FROM public.clienti
                            WHERE LOWER(nome) LIKE '""" + self._filter + """%' OR LOWER(cognome) LIKE '""" + self._filter + """%'                       
                        """)

    @pyqtSlot(str, str, str, str, str, result=bool)
    def addUser(self, nickname: str, name: str, surname: str, birthday: str, birthplace: str, password: str) -> bool:
        queryString = """
            INSERT INTO Utente (Nickname, Nome, Cognome, DataNascita, Luogo, Password)
            VALUES(:nickname, :name, :surname, :birthday, :birthplace, :password)
        """

        query = QSqlQuery()
        query.prepare()

        if not nickname or not name or not surname or not birthday or not password:
            return False

        query.bindValue(":fiscalCode", nickname)
        query.bindValue(":name", name)
        query.bindValue(":surname", surname)
        query.bindValue(":birthday", birthday)
        query.bindValue(":birthplace", birthplace)
        query.bindValue(":password", password)

        done = query.exec()
        return done

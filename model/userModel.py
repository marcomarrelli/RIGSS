import bcrypt

from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, pyqtSlot
from PyQt5.QtSql import QSqlQuery

from .baseModel import BaseModel

class UsersModel(BaseModel):
    def __init__(self, parent:QObject=None) -> None:
        super(UsersModel, self).__init__(["nickname", "nome", "cognome", "dataNascita", "luogo", "password"])
        super().setQuery("""SELECT nickname, nome, cognome, dataNascita, luogo, password 
                            FROM Utente;""")


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
        self._model.setQuery(f"""SELECT nickname, nome, cognome, dataNascita, luogo, password
                            FROM Utente
                            WHERE LOWER(nickname) LIKE '{self._filter}%' OR LOWER(nome) LIKE '{self._filter}%' OR LOWER(cognome) LIKE '{self._filter}%';""")

    @pyqtSlot(str, str, str, str, str, str, result=bool)
    def addUser(self, nickname: str, name: str, surname: str, birthday: str, birthplace: str, password: str) -> bool:
        query = QSqlQuery()
        query.prepare("""
            INSERT INTO Utente (nickname, nome, cognome, dataNascita, luogo, password)
            VALUES(:nickname, :name, :surname, :birthday, :birthplace, :password);
        """)

        if not nickname or not name or not surname or not password:
            return False

        query.bindValue(":nickname", nickname)
        query.bindValue(":name", name)
        query.bindValue(":surname", surname)
        query.bindValue(":birthday", birthday)
        query.bindValue(":birthplace", birthplace)
        query.bindValue(":password", bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8'))

        return query.exec()
    
    @pyqtSlot(str, result=bool)
    def userExists(self, nickname: str) -> bool:
        query = QSqlQuery()
        query.prepare("SELECT COUNT(*) FROM Utente WHERE LOWER(nickname) = LOWER(:nickname)")
        query.bindValue(":nickname", nickname)
        if query.exec() and query.next():
            count = query.value(0)
            return count > 0
        return False

    @pyqtSlot(str, str, result=bool)
    def login(self, nickname: str, password: str) -> bool:
        query = QSqlQuery()
        query.prepare("""
            SELECT password FROM Utente
            WHERE LOWER(nickname) = LOWER(:nickname)
        """)
        query.bindValue(":nickname", nickname)
        if query.exec() and query.next():
            return bcrypt.checkpw(password.encode('utf-8'), query.value(0).encode('utf-8'))

        return False
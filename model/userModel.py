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
    def addUser(self, fiscalCode: str, name: str, surname: str, dateOfBirth: str, password: str) -> bool:
        queryString = """
            INSERT INTO public.users (fiscalCode, name, surname, dateOfBirth, password)
            VALUES(:fiscalCode, :name, :surname, :dateOfBirth, :password)
        """

        query = QSqlQuery()
        query.prepare()

        if not fiscalCode or not name or not surname or not dateOfBirth or not password:
            return False

        query.bindValue(":fiscalCode", fiscalCode)
        query.bindValue(":name", name)
        query.bindValue(":surname", surname)
        query.bindValue(":dateOfBirth", dateOfBirth)
        query.bindValue(":password", password)

        done = query.exec()
        return done

    #@pyqtSlot(str, str, str, str, str, str)
    #def add(self, name: str, surname: str, taxcode: str, cellnum: str, email: str, companyName: str) -> bool:
    #    query = QSqlQuery()
    #    query.prepare("""INSERT INTO public.clienti
    #                    (cognome, nome, codice_fiscale, telefono, email, nome_azienda)
    #                    VALUES(:surname, :name, :taxcode, :cellnum, :email, :company)
    #                """)

    #    if not name or not surname or not taxcode:
    #        return False
    #    
    #    query.bindValue(":surname", surname)
    #    query.bindValue(":name", name)
    #    query.bindValue(":taxcode", taxcode)
    #    query.bindValue(":cellnum", cellnum)
    #    query.bindValue(":email", email)
    #    query.bindValue(":company", companyName)

    #    done = query.exec()
    #    return done

from PyQt5.QtCore import QObject, QByteArray, Qt
from PyQt5.QtSql import QSqlQueryModel

class BaseModel(QSqlQueryModel):
    def __init__(self, roles: list, parent:QObject=None) -> None:
        super(BaseModel, self).__init__()
        self.modelRoles = roles

    def roleNames(self):
        roles = {}
        for role in self.modelRoles:
            roles[Qt.UserRole + self.modelRoles.index(role) + 1] = QByteArray(role.encode())
        
        return roles

    def data(self, index, role):
        if role < Qt.UserRole:
            return super(BaseModel, self).data(index, role)

        return super(BaseModel, self).data(self.index(index.row(), role - Qt.UserRole -1), Qt.DisplayRole)

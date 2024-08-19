import sys
import os

from PyQt5.QtSql import QSqlDatabase, QSqlQuery

DATABASE_TYPE = "QSQLITE"

HOST_NAME = "localhost"
DATABASE_NAME = "RIGSS.sqlite3"

USERNAME = "root"
PASSWORD = "1234" # Top Security Level

def connect():
    database = QSqlDatabase.addDatabase(DATABASE_TYPE)

    if not database.isValid:
        print(f"Fatal Error: Cannot Create Database with '{DATABASE_TYPE}' Driver.")
        return False

    database.setHostName(HOST_NAME)
    database.setDatabaseName(DATABASE_NAME)
    database.setUserName(USERNAME)
    database.setPassword(PASSWORD)

    if not database.open():
        print(f"Fatal Error: Cannot Open Database '{DATABASE_NAME}'.")
        return False

    return True

def create():
    with open('init.sql', 'r') as file:
        script = file.read()
        queries = script.split(';')
        for query in queries:
            if query.strip():
                q = QSqlQuery()
                if not q.exec_(query.strip()): print(f"Failed to execute query. {q.lastError().text()}.")

def addNameLogo(query: QSqlQuery, tabella: str, nameValue: str, logoString: str):
    if tabella == "Carburante": query.prepare('INSERT INTO TipologiaCarburante(nome, logo) VALUES (?, ?);')
    elif tabella == "Bandiera": query.prepare('INSERT INTO Bandiera(nome, logo) VALUES (?, ?);')
    
    query.addBindValue(nameValue)
    query.addBindValue(logoString)
    
    return query.exec_()

def addFixedValues():
    q = QSqlQuery()

    with open("./gui/resources/benzina.svg", 'r') as file: benzina = file.read() or ""
    with open("./gui/resources/diesel.svg", 'r') as file: gasolio = file.read() or ""
    with open("./gui/resources/metano.svg", 'r') as file: metano = file.read() or ""
    with open("./gui/resources/gpl.svg", 'r') as file: gpl = file.read() or ""

    with open("./gui/resources/q8.svg", 'r') as file: q8 = file.read() or ""
    with open("./gui/resources/esso.svg", 'r') as file: esso = file.read() or ""
    with open("./gui/resources/agipEni.svg", 'r') as file: agipEni = file.read() or ""
    with open("./gui/resources/pompeBianche.svg", 'r') as file: pompeBianche = file.read() or ""
    with open("./gui/resources/agiIp.svg", 'r') as file: agiIp = file.read() or ""
    with open("./gui/resources/tamoil.svg", 'r') as file: tamoil = file.read() or ""

    addNameLogo(q, "Carburante", "Benzina", benzina)
    addNameLogo(q, "Carburante", "Gasolio", gasolio)
    addNameLogo(q, "Carburante", "Metano", metano)
    addNameLogo(q, "Carburante", "GPL", gpl)
    
    addNameLogo(q, "Bandiera", "Q8", q8)
    addNameLogo(q, "Bandiera", "Esso", esso)
    addNameLogo(q, "Bandiera", "Agip Eni", agipEni)
    addNameLogo(q, "Bandiera", "Pompe Bianche", pompeBianche)
    addNameLogo(q, "Bandiera", "Api-Ip", agiIp)
    addNameLogo(q, "Bandiera", "Tamoil", tamoil)

    q.exec_('INSERT INTO TipologiaPromozione(nome) VALUES ("Sconto");')
    q.exec_('INSERT INTO TipologiaPromozione(nome) VALUES ("Cashback");')

    q.exec_('INSERT INTO MetodoPagamento(nome) VALUES ("Contanti");')
    q.exec_('INSERT INTO MetodoPagamento(nome) VALUES ("Carta di Debito");')
    q.exec_('INSERT INTO MetodoPagamento(nome) VALUES ("Carta di Credito");')

    q.exec_('INSERT INTO Distributore(idImpianto, gestore, bandiera, tipologia, nome, via, numeroCivico, cap, comune, provincia, latitudine, longitudine, simulato) VALUES(0, "Mario Rossi", "Q8", "Tipo", "Rossi Gas", "Via Mario Rossi", "1", "00000", "Roma", "Roma", 41.90, 12.50, false)')

def initializeDatabase():
    isFirstInitialization = not os.path.exists(DATABASE_NAME)
    
    if not connect(): sys.exit(-1)
    if not isFirstInitialization: return

    create()
    addFixedValues()
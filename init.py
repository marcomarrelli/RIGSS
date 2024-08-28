import sys
import os
import random

from pathlib import Path

from PyQt5.QtSql import QSqlDatabase, QSqlQuery

DATABASE_TYPE = "QSQLITE"

HOST_NAME = "localhost"
DATABASE_NAME = "RIGSS.sqlite3"

USERNAME = "root"
PASSWORD = "1234" # Top Security Level

CURRENT_DIRECTORY = Path(__file__).resolve().parent


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

def close():
    database = QSqlDatabase.database()
    if database.isOpen(): database.close()
    QSqlDatabase.removeDatabase(DATABASE_NAME)
    print("Database Connection Closed.")

def create():
    try:
        with open(os.fspath(CURRENT_DIRECTORY / "init.sql"), 'r') as file:
            script = file.read()
            queries = script.split(';')
            for query in queries:
                if query.strip():
                    q = QSqlQuery()
                    if not q.exec_(query.strip()): print(f"Failed to execute query. {q.lastError().text()}.")
    except FileNotFoundError:
        print(f"Fatal Error: Cannot Initialize Database '{DATABASE_NAME}'.")
        return False

    return True


def addNameLogo(query: QSqlQuery, tabella: str, nameValue: str, logoString: str):
    if tabella == "Carburante": query.prepare('INSERT INTO TipologiaCarburante(nome, logo) VALUES (?, ?);')
    elif tabella == "Bandiera": query.prepare('INSERT INTO Bandiera(nome, logo) VALUES (?, ?);')
    
    query.addBindValue(nameValue)
    query.addBindValue(logoString)
    
    return query.exec_()


def addFixedValues():
    q = QSqlQuery()

    with open(os.fspath(CURRENT_DIRECTORY / "gui" / "resources" / "benzina.svg"), 'r') as file: benzina = file.read() or ""
    with open(os.fspath(CURRENT_DIRECTORY / "gui" / "resources" / "gasolio.svg"), 'r') as file: gasolio = file.read() or ""
    with open(os.fspath(CURRENT_DIRECTORY / "gui" / "resources" / "metano.svg"), 'r') as file: metano = file.read() or ""
    with open(os.fspath(CURRENT_DIRECTORY / "gui" / "resources" / "gpl.svg"), 'r') as file: gpl = file.read() or ""

    with open(os.fspath(CURRENT_DIRECTORY / "gui" / "resources" / "q8.svg"), 'r') as file: q8 = file.read() or ""
    with open(os.fspath(CURRENT_DIRECTORY / "gui" / "resources" / "esso.svg"), 'r') as file: esso = file.read() or ""
    with open(os.fspath(CURRENT_DIRECTORY / "gui" / "resources" / "agipEni.svg"), 'r') as file: agipEni = file.read() or ""
    with open(os.fspath(CURRENT_DIRECTORY / "gui" / "resources" / "pompeBianche.svg"), 'r') as file: pompeBianche = file.read() or ""
    with open(os.fspath(CURRENT_DIRECTORY / "gui" / "resources" / "agiIp.svg"), 'r') as file: agiIp = file.read() or ""
    with open(os.fspath(CURRENT_DIRECTORY / "gui" / "resources" / "tamoil.svg"), 'r') as file: tamoil = file.read() or ""

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

    q.exec_('INSERT INTO TipologiaSconto(nome) VALUES ("Sconto");')
    q.exec_('INSERT INTO TipologiaSconto(nome) VALUES ("Cashback");')

    q.exec_('INSERT INTO MetodoPagamento(nome) VALUES ("Contanti");')
    q.exec_('INSERT INTO MetodoPagamento(nome) VALUES ("Carta di Debito");')
    q.exec_('INSERT INTO MetodoPagamento(nome) VALUES ("Carta di Credito");')

    return True


def addGasStationsFromFile(gsfp=os.fspath(CURRENT_DIRECTORY / "model" / "resources" / "anagrafica_impianti_attivi.csv"), fpfp=os.fspath(CURRENT_DIRECTORY / "model" / "resources" / "prezzo_alle_8.csv"), n=50):
    q = QSqlQuery()
    
    flags = ["Q8", "Esso", "Agip Eni", "Pompe Bianche", "Api-Ip", "Tamoil"]
    fuels = ["Benzina", "Gasolio", "Metano", "GPL"]

    loadedIDs = []

    print("Loading Gas Stations...")

    try:
        with open(gsfp, 'r', encoding='utf-8') as file:
            lines = file.readlines()

        if len(lines) < n:
            return False

        lines = lines[2:]
        rl = random.sample(lines, n)

        for r in rl:
            temp = r.strip().split(';')
            
            if temp[2] not in flags:
                print(f"Bandiera '{temp[2]}' non Valida! Carico Prossimo Distributore...")
                continue

            if temp[8] == '' or temp[9] == '':
                print(f"Coordinate non Valide! Carico Prossimo Distributore...")
                continue

            cap = temp[5][-5:]
            if not cap.isnumeric(): cap = "N/A"

            q.prepare('INSERT INTO Distributore(idImpianto, gestore, bandiera, tipologia, nome, via, cap, comune, provincia, latitudine, longitudine, simulato) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);')

            q.addBindValue(temp[0]) # ID
            q.addBindValue(temp[1]) # Gestore
            q.addBindValue(temp[2]) # Bandiera
            q.addBindValue(temp[3]) # Tipologia
            q.addBindValue(temp[4]) # Nome
            q.addBindValue(temp[5]) # Via
            q.addBindValue(cap) # CAP: gli ultimi 5 caratteri del parametro 'via'
            q.addBindValue(temp[6]) # Comune
            q.addBindValue(temp[7]) # Provincia
            q.addBindValue(temp[8])
            q.addBindValue(temp[9])
            q.addBindValue(False) # simulato = false
            
            if q.exec_(): loadedIDs.append(temp[0])
            else: continue

    except FileNotFoundError:
        print(f"Mimit Gov. Anagraphic File Not Found. Download It Online and Place It in 'model/resources'.")
        return False
    
    print("Loading Fuel Prices...")

    try:
        with open(fpfp, 'r', encoding='utf-8') as file:
            lines = file.readlines()

        lines = lines[2:]

        for r in lines:
            temp = r.strip().split(';')

            if temp[0] not in loadedIDs: continue

            if temp[1] not in fuels:
                print(f"Fuel '{temp[1]}' not Valid! Loading Next Fuel...")
                continue

            q.prepare('INSERT INTO Carburante(idImpianto, nome, prezzo, self, dataAggiornamento) VALUES(?, ?, ?, ?, ?);')

            q.addBindValue(temp[0]) # ID
            q.addBindValue(temp[1]) # Nome
            q.addBindValue(temp[2]) # Prezzo
            q.addBindValue(temp[3]) # Self
            q.addBindValue(temp[4]) # DataAggiornamento
            
            if not q.exec_(): continue

    except FileNotFoundError:
        print(f"Mimit Gov. Price File Not Found. Download It Online and Place It in 'model/resources'.")
        return False
    
    print("Finish Loading MIMIT GOV. Data.")
    return True


def initializeDatabase(gsn=50):
    isFirstInitialization = not os.path.exists(DATABASE_NAME)
    
    if not connect(): return False
    if not isFirstInitialization: return True

    if not create(): return False
    if not addFixedValues(): return False
    if not addGasStationsFromFile(n=gsn): return False
    
    return True

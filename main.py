# RIGSS (Realistic Italian Gas Station Simulator)
# Authors: Marco Marrelli & Margherita Zanchini
# Version: 0.1

"""
Un Simulatore Realistico per la Gestione di un Impianto di Distribuzione Carburante

L'obiettivo del progetto è realizzare un'applicazione desktop per simulare in maniera realistica la visualizzazione e gestione di uno (o più) impianti di distribuzione carburante in Italia,
popolando il database tramite dataset pubblici distribuiti dal governo italiano (https://www.mimit.gov.it/it/open-data/elenco-dataset/carburanti-prezzi-praticati-e-anagrafica-degli-impianti).

La piattaforma permetterà di:
- Visualizzare su mappa una lista di distributori di carburante sul suolo italiano (sia reali che creati virtualmente da noi);
- Visualizzare le informazioni di un distributore selezionato (restituite dal dataset, come nome, bandiera, posizione, prezzi del carburante ecc...);
- Visualizzare la lista dei distributori filtrata da parametri dati passati dall'utente (per nome, per prezzo maggiore/minore, avente una specifica bandiera, avente una specifica posizione ecc...);
- Visualizzare un insieme di statistiche generale o per zona (come la media e la moda dei prezzi);
- Visualizzare le stazione distribuzione dove è stato venduto maggiormente un determinato carburante, e quelle dove è stato venduto in minor misura;
- Visualizzare un elenco dei distributori con le migliori valutazioni (da 4 stelle in su).

Ogni utente potrà:
- Consultare l'applicazione liberamente (senza registrazione o login);
- Registrarsi (tramite un parametro unico, come codice fiscale o nome utente, più altri parametri personali, come nome, cognome, data di nascita e password);
- Loggarsi nel sistema (tramite parametro unico e password) nel sistema;
- Registrare sul database degli impianti di carburante (aventi come proprietario l'utente stesso);
- Aggiungere o modificare i dati (come il prezzo, le tipologie di carburante disponibili...) dei distributori di proprietà dell'utente;
- Creare e salvare nel database le transazioni effettuate presso gli impianti, insieme ai relativi dettagli quali data, ora, tipo di carburante, quantità, costo totale;
- Valutare i distributori presenti sulla piattaforma (da 1 a 5 stelle) e scrivere una recensione, ogni utente potrà recensire un determinato distributore solo dopo aver effettuato una transazione presso quell'impianto.

Se l'utente è loggato come amministratore di sistema, allora potrà:
- Creare, eliminare o modificare ogni impianto (anche se non di sua proprietà);
- Modificare la lista degli utenti, creandone di nuovi o eliminandone di già esistenti;
- Caricare, tramite file .csv o .json, uno o più impianti di distribuzione;
- Esportare i dati dei distributori.
"""

import os
import sys
# import logging

from pathlib import Path

from PyQt5.QtCore import QUrl
from PyQt5.QtQml import QQmlApplicationEngine, qmlRegisterType, qmlRegisterSingletonType
from PyQt5.QtGui import QGuiApplication, QFontDatabase

from init import initializeDatabase, close as closeDatabaseConnection

from model.baseModel import BaseModel
from model.gasStationModel import GasStations
from model.userModel import Users
from model.statisticsModel import Statistics

CURRENT_DIRECTORY = Path(__file__).resolve().parent
GAS_STATIONS_NUMBER = 100

mainFilePath = QUrl.fromLocalFile(os.fspath(CURRENT_DIRECTORY / "gui" / "RIGSS.qml"))
themeFilePath = QUrl.fromLocalFile(os.fspath(CURRENT_DIRECTORY / "gui" / "Theme.qml"))

if __name__ == '__main__':
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("Marrelli and Zanchini")
    app.setApplicationName("RIGSS")

    if not initializeDatabase(gsn=GAS_STATIONS_NUMBER):
        print("FATAL: Couldn't Initialize Database.")
        closeDatabaseConnection()
        if os.path.exists("RIGSS.sqlite3"): os.remove("RIGSS.sqlite3")
        sys.exit(-1)

    qmlRegisterType(GasStations, 'GasStations', 1, 0, 'GasStations')
    qmlRegisterType(Users, 'Users', 1, 0, 'Users')
    qmlRegisterType(Statistics, 'Statistics', 1, 0, 'Statistics')
    
    qmlRegisterSingletonType(themeFilePath, 'ApplicationSettings', 1, 0, 'Theme')

    fontCheck = QFontDatabase.addApplicationFont(os.fspath(CURRENT_DIRECTORY / "gui" / "resources" / "Phosphor.ttf"))
    if fontCheck < 0:
        print("FATAL: 'Phosphor' Font Not Found.")
        sys.exit(-1)

    engine = QQmlApplicationEngine()
    engine.quit.connect(app.quit)

    engine.load(mainFilePath)

    if not engine.rootObjects():
        print("FATAL: Engine Fatal Error")
        sys.exit(-1)

    sys.exit(app.exec())

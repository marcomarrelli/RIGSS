# RIGSS (Realistic Italian Gas Station Simulator)
# Authors: Marco Marrelli & Margherita Zanchini
# Version: 0.1

import os
import sys
# import logging

from pathlib import Path

from PyQt5.QtCore import QUrl
from PyQt5.QtQml import QQmlApplicationEngine, qmlRegisterSingletonType
from PyQt5.QtGui import QGuiApplication, QFontDatabase

from init import initializeDatabase

CURRENT_DIRECTORY = Path(__file__).resolve().parent

mainFilePath = QUrl.fromLocalFile(os.fspath(CURRENT_DIRECTORY / "gui" / "RIGSS.qml"))
themeFilePath = QUrl.fromLocalFile(os.fspath(CURRENT_DIRECTORY / "gui" / "Theme.qml"))

if __name__ == '__main__':
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("Marrelli and Zanchini")
    app.setApplicationName("RIGSS")

    initializeDatabase()

    qmlRegisterSingletonType(themeFilePath, 'ApplicationSettings', 1, 0, 'Theme')

    fontCheck = QFontDatabase.addApplicationFont(os.fspath(CURRENT_DIRECTORY / "gui" / "resources" / "Phosphor.ttf"))
    if fontCheck < 0:
        print("FATAL: 'Phosphor Duotone' Font Not Found.")
        sys.exit(-1)

    engine = QQmlApplicationEngine()
    engine.quit.connect(app.quit)

    engine.load(mainFilePath)

    if not engine.rootObjects():
        print("FATAL: Engine Fatal Error")
        sys.exit(-1)

    sys.exit(app.exec())

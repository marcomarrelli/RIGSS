from PyQt5.QtCore import QObject, pyqtSlot, pyqtProperty
from PyQt5.QtSql import QSqlQuery

from statistics import stdev, mode, StatisticsError

from .baseModel import BaseModel

class Statistics(BaseModel):
    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)

        self._averagePrice = 0.0
        self._modePrice = 0.0
        self._minPrice = 0.0
        self._maxPrice = 0.0
        self._distributorsCity = 0
        self._distributorsProvince = 0
        self._standardDeviationPrice = 0.0
        self._averagePriceProvince = 0.0
        self._fuelTypeDistribution = 0.0
        self._priceDifferenceSelfService = 0.0

    @pyqtSlot(str)
    def calculateAveragePrice(self, fuelType: str) -> None:
        query = QSqlQuery()
        query.prepare("""
            SELECT AVG(prezzo) 
            FROM Carburante 
            WHERE nome = :fuelType
        """)
        query.bindValue(":fuelType", fuelType)
        query.exec_()
        
        if query.next():
            self._averagePrice = query.value(0)
        else:
            self._averagePrice = 0.0

    @pyqtSlot(str)
    def calculateModePrice(self, fuelType: str) -> None:
        query = QSqlQuery()
        query.prepare("""
            SELECT prezzo 
            FROM Carburante 
            WHERE nome = :fuelType
        """)
        query.bindValue(":fuelType", fuelType)
        query.exec_()

        prices = []
        while query.next(): prices.append(query.value(0))
        
        try: self._modePrice = mode(prices)
        except StatisticsError: self._modePrice = 0.0 

    @pyqtSlot(str)
    def calculateMinPrice(self, fuelType: str) -> None:
        query = QSqlQuery()
        query.prepare("""
            SELECT MIN(prezzo) 
            FROM Carburante 
            WHERE nome = :fuelType
        """)
        query.bindValue(":fuelType", fuelType)
        query.exec_()
        
        if query.next():
            self._minPrice = query.value(0)
        else:
            self._minPrice = 0.0

    @pyqtSlot(str)
    def calculateMaxPrice(self, fuelType: str) -> None:
        query = QSqlQuery()
        query.prepare("""
            SELECT MAX(prezzo) 
            FROM Carburante 
            WHERE nome = :fuelType
        """)
        query.bindValue(":fuelType", fuelType)
        query.exec_()
        
        if query.next():
            self._maxPrice = query.value(0)
        else:
            self._maxPrice = 0.0

    @pyqtSlot(str)
    def calculateDistributorsInCity(self, city: str) -> None:
        query = QSqlQuery()
        query.prepare("""
            SELECT COUNT(idImpianto) 
            FROM Distributore 
            WHERE comune = :city
        """)
        query.bindValue(":city", city)
        query.exec_()

        if query.next():
            self._distributorsCity = query.value(0)
        else:
            self._distributorsCity = 0
    
    @pyqtSlot(str)
    def calculateDistributorsInProvince(self, province: str) -> None:
        query = QSqlQuery()
        query.prepare("""
            SELECT COUNT(idImpianto) 
            FROM Distributore 
            WHERE provincia = :province
        """)
        query.bindValue(":province", province)
        query.exec_()

        if query.next():
            self._distributorsProvince = query.value(0)
        else:
            self._distributorsProvince = 0

    @pyqtSlot(str, result=float)
    def calculateStandardDeviationPrice(self, fuelType: str) -> float:
        query = QSqlQuery()
        query.prepare("""
            SELECT prezzo 
            FROM Carburante 
            WHERE nome = :fuelType
        """)
        query.bindValue(":fuelType", fuelType)
        query.exec_()

        prices = []
        while query.next():
            prices.append(query.value(0))
        
        try:
            self._standardDeviationPrice = stdev(prices)
        except StatisticsError:
            self._standardDeviationPrice = 0.0
        
        return self._standardDeviationPrice

    @pyqtSlot(str, str, result=float)
    def calculateAveragePriceProvince(self, fuelType: str, province: str) -> float:
        query = QSqlQuery()
        query.prepare("""
            SELECT AVG(prezzo) 
            FROM Carburante 
            JOIN Distributore ON Carburante.idImpianto = Distributore.idImpianto
            WHERE Carburante.nome = :fuelType AND Distributore.provincia = :province
        """)
        query.bindValue(":fuelType", fuelType)
        query.bindValue(":province", province)
        query.exec_()
        
        if query.next():
            self._averagePriceProvince = query.value(0)
        else:
            self._averagePriceProvince = 0.0
        
        return self._averagePriceProvince

    @pyqtSlot(str, result=float)
    def calculateFuelTypeDistribution(self, name: str) -> float:
        query = QSqlQuery("""
            SELECT nome, COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Carburante) AS percentage
            FROM Carburante
            WHERE name = :name
        """)
        query.bindValue(":name", name)
        query.exec_()

        if query.next():
            self._fuelTypeDistribution = query.value(0)
        else:
            self._fuelTypeDistribution = 0.0

        return self._fuelTypeDistribution

    @pyqtSlot(str, result=float)
    def calculatePriceDifferenceSelfService(self, fuelType: str) -> float:
        query = QSqlQuery()
        query.prepare("""
            SELECT AVG(prezzo) 
            FROM Carburante 
            WHERE nome = :fuelType AND self = 1
        """)
        query.bindValue(":fuelType", fuelType)
        query.exec_()
        
        if query.next():
            selfServicePrice = query.value(0)
        else:
            selfServicePrice = 0.0

        query.prepare("""
            SELECT AVG(prezzo) 
            FROM Carburante 
            WHERE nome = :fuelType AND self = 0
        """)
        query.bindValue(":fuelType", fuelType)
        query.exec_()
        
        if query.next():
            fullServicePrice = query.value(0)
        else:
            fullServicePrice = 0.0

        self._priceDifferenceSelfService = fullServicePrice - selfServicePrice
        return self._priceDifferenceSelfService

    @pyqtProperty(float)
    def averagePrice(self) -> float: return self._averagePrice

    @pyqtProperty(float)
    def modePrice(self) -> float: return self._modePrice

    @pyqtProperty(float)
    def minPrice(self) -> float: return self._minPrice

    @pyqtProperty(float)
    def maxPrice(self) -> float: return self._maxPrice
    
    @pyqtProperty(int)
    def distributorsCity(self) -> int: return self._distributorsCity

    @pyqtProperty(int)
    def distributorsProvince(self) -> int: return self._distributorsProvince
    
    @pyqtProperty(float)
    def standardDeviationPrice(self) -> float: return self._standardDeviationPrice
    
    @pyqtProperty(float)
    def averagePriceProvince(self) -> float: return self._averagePriceProvince
    
    @pyqtProperty(float)
    def fuelTypeDistribution(self) -> float: return self._fuelTypeDistribution

    @pyqtProperty(float)
    def priceDifferenceSelfService(self) -> float: return self._priceDifferenceSelfService
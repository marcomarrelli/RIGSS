from PyQt5.QtCore import QObject, pyqtSlot, pyqtProperty, pyqtSignal
from PyQt5.QtSql import QSqlQuery

from statistics import stdev, mode, StatisticsError

from .baseModel import BaseModel

class Statistics(BaseModel):
    averagePriceChanged = pyqtSignal()
    modePriceChanged = pyqtSignal()
    minPriceChanged = pyqtSignal()
    maxPriceChanged = pyqtSignal()
    distributorsCityChanged = pyqtSignal()
    distributorsProvinceChanged = pyqtSignal()
    standardDeviationPriceChanged = pyqtSignal()
    averagePriceProvinceChanged = pyqtSignal()
    fuelTypeDistributionChanged = pyqtSignal()
    priceDifferenceSelfServiceChanged = pyqtSignal()

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
    def getFuelStatistics(self, fuelType: str) -> None:
        self.calculateAveragePrice(fuelType)
        self.calculateModePrice(fuelType)
        self.calculateMinPrice(fuelType)
        self.calculateMaxPrice(fuelType)
        self.calculateStandardDeviationPrice(fuelType)
        self.calculateFuelTypeDistribution(fuelType)
        self.calculatePriceDifferenceSelfService(fuelType)

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
            self._averagePrice = query.value(0) if query.value(0) != "" else 0.0
        else:
            self._averagePrice = 0.0

        self.averagePriceChanged.emit()

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
        while query.next(): prices.append(query.value(0) if query.value(0) != "" else 0.0)
        
        try: self._modePrice = mode(prices)
        except StatisticsError: self._modePrice = 0.0

        self.modePriceChanged.emit()

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
            self._minPrice = query.value(0) if query.value(0) != "" else 0.0
        else:
            self._minPrice = 0.0

        self.minPriceChanged.emit()
    
    @pyqtSlot(str)
    def calculateMaxPrice(self, fuelType: str) -> None:
        query = QSqlQuery()
        query.prepare("""
            SELECT MAX(prezzo), idImpianto
            FROM Carburante
            WHERE nome = :fuelType
        """)
        query.bindValue(":fuelType", fuelType)
        query.exec_()
        
        if query.next():
            self._maxPrice = query.value(0) if query.value(0) != "" else 0.0
        else:
            self._maxPrice = 0.0

        self.maxPriceChanged.emit()

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
            self._distributorsCity = query.value(0) if query.value(0) != "" else 0
        else:
            self._distributorsCity = 0

        self.distributorsCityChanged.emit()
    
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
            self._distributorsProvince = query.value(0) if query.value(0) != "" else 0
        else:
            self._distributorsProvince = 0

        self.distributorsProvinceChanged.emit()

    @pyqtSlot(str)
    def calculateStandardDeviationPrice(self, fuelType: str) -> None:
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
            prices.append(query.value(0) if query.value(0) != "" else 0.0)
        
        try:
            self._standardDeviationPrice = stdev(prices)
        except StatisticsError:
            self._standardDeviationPrice = 0.0

        self.standardDeviationPriceChanged.emit()
    
    @pyqtSlot(str, str)
    def calculateAveragePriceProvince(self, fuelType: str, province: str) -> None:
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
            self._averagePriceProvince = query.value(0) if query.value(0) != "" else 0.0
        else:
            self._averagePriceProvince = 0.0

        self.averagePriceProvinceChanged.emit()

    @pyqtSlot(str)
    def calculateFuelTypeDistribution(self, fuelType: str) -> None:
        query = QSqlQuery()
        query.prepare("""
            SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Carburante)) AS percentage
            FROM Carburante
            WHERE nome = :fuelType
        """)
        query.bindValue(":fuelType", fuelType)
        query.exec_()
        
        if query.next():
            self._fuelTypeDistribution = query.value(0) if query.value(0) is not None else 0.0
        else:
            self._fuelTypeDistribution = 0.0

        self.fuelTypeDistributionChanged.emit()

    @pyqtSlot(str)
    def calculatePriceDifferenceSelfService(self, fuelType: str) -> None:
        query = QSqlQuery()
        query.prepare("""
            SELECT AVG(prezzo) 
            FROM Carburante 
            WHERE nome = :fuelType AND self = 1
        """)
        query.bindValue(":fuelType", fuelType)
        query.exec_()
        
        if query.next():
            selfServicePrice = query.value(0) if query.value(0) != "" else 0.0
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
            fullServicePrice = query.value(0) if query.value(0) != "" else 0.0 
        else:
            fullServicePrice = 0.0

        self._priceDifferenceSelfService = fullServicePrice - selfServicePrice
        self.priceDifferenceSelfServiceChanged.emit()

    @pyqtProperty(float, notify=averagePriceChanged)
    def averagePrice(self) -> float: return self._averagePrice

    @pyqtProperty(float, notify=modePriceChanged)
    def modePrice(self) -> float: return self._modePrice

    @pyqtProperty(float, notify=minPriceChanged)
    def minPrice(self) -> float: return self._minPrice

    @pyqtProperty(float, notify=maxPriceChanged)
    def maxPrice(self) -> float: return self._maxPrice
    
    @pyqtProperty(int, notify=distributorsCityChanged)
    def distributorsCity(self) -> int: return self._distributorsCity

    @pyqtProperty(int, notify=distributorsProvinceChanged)
    def distributorsProvince(self) -> int: return self._distributorsProvince
    
    @pyqtProperty(float, notify=standardDeviationPriceChanged)
    def standardDeviationPrice(self) -> float: return self._standardDeviationPrice
    
    @pyqtProperty(float, notify=averagePriceProvinceChanged)
    def averagePriceProvince(self) -> float: return self._averagePriceProvince
    
    @pyqtProperty(float, notify=fuelTypeDistributionChanged)
    def fuelTypeDistribution(self) -> float: return self._fuelTypeDistribution

    @pyqtProperty(float, notify=priceDifferenceSelfServiceChanged)
    def priceDifferenceSelfService(self) -> float: return self._priceDifferenceSelfService
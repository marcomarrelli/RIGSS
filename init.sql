DROP TABLE IF EXISTS Distributore;
DROP TABLE IF EXISTS TipologiaCarburante;
DROP TABLE IF EXISTS Bandiera;
DROP TABLE IF EXISTS Carburante;
DROP TABLE IF EXISTS Utente;
DROP TABLE IF EXISTS Valutazione;
DROP TABLE IF EXISTS MetodoPagamento;
DROP TABLE IF EXISTS Transazione;
DROP TABLE IF EXISTS Fattura;
DROP TABLE IF EXISTS Promozione;
DROP TABLE IF EXISTS TipologiaPromozione;

CREATE TABLE Bandiera (
    Nome VARCHAR(31) NOT NULL,
	Logo TEXT,
	PRIMARY KEY (Nome)
);

CREATE TABLE TipologiaCarburante (
    Nome VARCHAR(31) NOT NULL,
    Logo TEXT,
    PRIMARY KEY (Nome)
);

CREATE TABLE Distributore (
    IDImpianto INTEGER NOT NULL,
	Gestore VARCHAR(255) NOT NULL,
    Bandiera VARCHAR(31) NOT NULL,
    Tipologia VARCHAR(63) NOT NULL,
    Nome VARCHAR(127) NOT NULL,
	Via VARCHAR(127) NOT NULL,
    NumeroCivico VARCHAR(15) NOT NULL,
    CAP VARCHAR(5) NOT NULL,
    Comune VARCHAR(63) NOT NULL,
    Provincia VARCHAR(63) NOT NULL,
	Latitudine REAL NOT NULL,
    Longitudine REAL NOT NULL,
	eSimulato BOOLEAN NOT NULL,
	PRIMARY KEY (IDImpianto),
    FOREIGN KEY (Bandiera) REFERENCES Bandiera(Nome)
);

CREATE TABLE Carburante (
    IDImpianto INTEGER NOT NULL,
	Nome VARCHAR(31) NOT NULL,
    Prezzo DECIMAL(6, 3) NOT NULL,
    eSelf BOOLEAN NOT NULL,
    DataAggiornamento DATETIME NOT NULL,
	PRIMARY KEY (IDImpianto, Nome, eSelf),
    FOREIGN KEY (Nome) REFERENCES TipologiaCarburante(Nome)
);

CREATE TABLE Utente (
    Nickname VARCHAR(31) NOT NULL,
    Nome VARCHAR(31) NOT NULL,
    Cognome VARCHAR(31) NOT NULL,
    DataNascita DATE NOT NULL,
    Luogo VARCHAR(63) NOT NULL,
    Password VARCHAR(15) NOT NULL,
	PRIMARY KEY (Nickname)
);

CREATE TABLE Valutazione (
    IDValutazione INTEGER NOT NULL,
	IDImpianto INTEGER NOT NULL,
    IDUtente VARCHAR(31) NOT NULL,
	Valutazione INTEGER NOT NULL,
    Recensione VARCHAR(255),
	PRIMARY KEY (IDValutazione),
    FOREIGN KEY (IDImpianto) REFERENCES Distributore(IDImpianto),
    FOREIGN KEY (IDUtente) REFERENCES Utente(Nickname),
	CONSTRAINT CheckValutazione CHECK (Valutazione BETWEEN 0 AND 5)
);

CREATE TABLE MetodoPagamento (
    IDMetodoPagamento INTEGER NOT NULL,
    Nome VARCHAR(31) NOT NULL,
	PRIMARY KEY (IDMetodoPagamento)
);

CREATE TABLE Transazione (
    IDTransazione INTEGER NOT NULL,
	IDImpianto INTEGER NOT NULL,
    IDUtente VARCHAR(31) NOT NULL,
    MetodoPagamento INTEGER NOT NULL,
	Quantita DECIMAL(5, 2) NOT NULL,
    Tipologia VARCHAR(31) NOT NULL,
    Servito BOOLEAN NOT NULL,
    Spesa DECIMAL(6, 2) NOT NULL,
    DataTransazione DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (IDTransazione),
    FOREIGN KEY (IDImpianto) REFERENCES Distributore(IDImpianto),
    FOREIGN KEY (IDUtente) REFERENCES Utente(Nickname),
    FOREIGN KEY (MetodoPagamento) REFERENCES MetodoPagamento(IDMetodoPagamento)
);

CREATE TABLE Fattura (
    IDFattura INTEGER NOT NULL,
	IDTransazione INTEGER NOT NULL,
	Importo DECIMAL(6, 2) NOT NULL,
    DataEmissione DATETIME NOT NULL,
	PRIMARY KEY (IDFattura),
    FOREIGN KEY (IDTransazione) REFERENCES Transazione(IDTransazione)
);

CREATE TABLE TipologiaPromozione (
    IDTipologiaPromozione INTEGER NOT NULL,
	Nome VARCHAR(31) NOT NULL,
	PRIMARY KEY (IDTipologiaPromozione)
);

CREATE TABLE Promozione (
    IDPromozione INTEGER NOT NULL,
    IDTipologiaPromozione INTEGER NOT NULL,
	Valore DECIMAL(5, 2) NOT NULL,
	PRIMARY KEY (IDPromozione),
    FOREIGN KEY (IDTipologiaPromozione) REFERENCES TipologiaPromozione(IDTipologiaPromozione),
	CONSTRAINT CheckValore CHECK (Valore BETWEEN 0.00 AND 100.00)
);
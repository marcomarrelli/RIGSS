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
    nome VARCHAR(31) NOT NULL,
	logo TEXT,
	PRIMARY KEY (nome)
);

CREATE TABLE TipologiaCarburante (
    nome VARCHAR(31) NOT NULL,
    logo TEXT,
    PRIMARY KEY (nome)
);

CREATE TABLE Distributore (
    idImpianto INTEGER NOT NULL,
	gestore VARCHAR(255) NOT NULL,
    bandiera VARCHAR(31) NOT NULL,
    tipologia VARCHAR(63) NOT NULL,
    nome VARCHAR(127) NOT NULL,
	via VARCHAR(127) NOT NULL,
    cap VARCHAR(5) NOT NULL,
    comune VARCHAR(63) NOT NULL,
    provincia VARCHAR(4) NOT NULL,
	latitudine REAL NOT NULL,
    longitudine REAL NOT NULL,
	simulato BOOLEAN NOT NULL,
	PRIMARY KEY (idImpianto),
    FOREIGN KEY (bandiera) REFERENCES Bandiera(nome)
);

CREATE TABLE Carburante (
    idImpianto INTEGER NOT NULL,
	nome VARCHAR(31) NOT NULL,
    prezzo DECIMAL(6, 3) NOT NULL,
    self BOOLEAN NOT NULL,
    dataAggiornamento DATETIME,
	PRIMARY KEY (idImpianto, nome, self),
    FOREIGN KEY (nome) REFERENCES TipologiaCarburante(nome)
);

CREATE TABLE Utente (
    nickname VARCHAR(31) NOT NULL,
    nome VARCHAR(31) NOT NULL,
    cognome VARCHAR(31) NOT NULL,
    dataNascita DATE,
    luogo VARCHAR(63),
    password VARCHAR(15) NOT NULL,
	PRIMARY KEY (nickname)
);

CREATE TABLE Valutazione (
    idValutazione INTEGER NOT NULL,
	idImpianto INTEGER NOT NULL,
    idUtente VARCHAR(31) NOT NULL,
	stelle INTEGER NOT NULL,
    recensione VARCHAR(255),
	PRIMARY KEY (idValutazione),
    FOREIGN KEY (idImpianto) REFERENCES Distributore(idImpianto),
    FOREIGN KEY (idUtente) REFERENCES Utente(nickname),
	CONSTRAINT CheckValutazione CHECK (stelle BETWEEN 0 AND 5)
);

CREATE TABLE MetodoPagamento (
    idMetodoPagamento INTEGER NOT NULL,
    nome VARCHAR(31) NOT NULL,
	PRIMARY KEY (idMetodoPagamento)
);

CREATE TABLE Transazione (
    idTransazione INTEGER NOT NULL,
	idImpianto INTEGER NOT NULL,
    idUtente VARCHAR(31) NOT NULL,
    metodoPagamento INTEGER NOT NULL,
    tipologia VARCHAR(31) NOT NULL,
    servito BOOLEAN NOT NULL,
	quantita DECIMAL(5, 2) NOT NULL,
    spesa DECIMAL(6, 2) NOT NULL,
    dataTransazione DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (idTransazione),
    FOREIGN KEY (idImpianto) REFERENCES Carburante(idImpianto),
    FOREIGN KEY (idUtente) REFERENCES Utente(nickname),
    FOREIGN KEY (metodoPagamento) REFERENCES MetodoPagamento(idMetodoPagamento),
    FOREIGN KEY (tipologia) REFERENCES Carburante(nome),
    FOREIGN KEY (servito) REFERENCES Carburante(self)
);

CREATE TABLE Fattura (
    idFattura INTEGER NOT NULL,
	idTransazione INTEGER NOT NULL,
	importo DECIMAL(6, 2) NOT NULL,
    dataEmissione DATETIME NOT NULL,
	PRIMARY KEY (idFattura),
    FOREIGN KEY (idTransazione) REFERENCES Transazione(idTransazione)
);

CREATE TABLE TipologiaSconto (
    idTipologiaSconto INTEGER NOT NULL,
	nome VARCHAR(31) NOT NULL,
	PRIMARY KEY (idTipologiaSconto)
);

CREATE TABLE Sconto (
    idPromozione INTEGER NOT NULL,
    idTipologiaSconto INTEGER NOT NULL,
	valore DECIMAL(5, 2) NOT NULL,
	PRIMARY KEY (idPromozione),
    FOREIGN KEY (idTipologiaSconto) REFERENCES TipologiaPromozione(idTipologiaSconto),
	CONSTRAINT CheckValore CHECK (valore BETWEEN 0.00 AND 100.00)
);
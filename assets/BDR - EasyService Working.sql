
-- -----------------------------------------------------
-- Schema EasyService
-- -----------------------------------------------------
-- Projet BDR EasyService Groupe 6.
DROP SCHEMA IF EXISTS EasyService ;

-- -----------------------------------------------------
-- Schema EasyService
--
-- Projet BDR EasyService Groupe 6.
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS EasyService DEFAULT CHARACTER SET utf8mb4 ;
USE EasyService ;

-- -----------------------------------------------------
-- Table Staff
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Staff (
	id INT UNSIGNED AUTO_INCREMENT,
	nom VARCHAR(45) NOT NULL,
	prenom VARCHAR(45) NOT NULL,
	dateNaissance DATE NOT NULL,
	actif TINYINT NOT NULL,
    
	CONSTRAINT PK_Staff PRIMARY KEY (id),
	CONSTRAINT UC_Staff_nom_prenom_dateNaissance UNIQUE (nom, prenom, dateNaissance)
  );
-- -----------------------------------------------------
-- Table Service
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Service (
	id INT UNSIGNED AUTO_INCREMENT,
	debut TIME NOT NULL,
	fin TIME,
	actif TINYINT NOT NULL,
  
	CONSTRAINT PK_Service PRIMARY KEY (id),
    CONSTRAINT UC_Service_debut_fin UNIQUE (debut, fin)
);


-- -----------------------------------------------------
-- Table TableSalle
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS TableSalle (
	id INT UNSIGNED AUTO_INCREMENT,
	ouvertFerme TINYINT NOT NULL,
  
	CONSTRAINT PK_TableSalle PRIMARY KEY (id)
);

-- -----------------------------------------------------
-- Table Commande
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Commande (
	id INT UNSIGNED AUTO_INCREMENT,
	nombreCouverts INT UNSIGNED NOT NULL,
	idStaff INT UNSIGNED NOT NULL,
	idService INT UNSIGNED NOT NULL,
	idTableSalle INT UNSIGNED NOT NULL,
    idAddition INT UNSIGNED ,
  
	CONSTRAINT PK_Commande PRIMARY KEY (id)
);

-- -----------------------------------------------------
-- Table Categorie
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Categorie (
	id INT UNSIGNED AUTO_INCREMENT,
	nom VARCHAR(45) NOT NULL UNIQUE,
  
	CONSTRAINT PK_Categorie PRIMARY KEY (id)
);

-- -----------------------------------------------------
-- Table Produit
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Produit (
	id INT UNSIGNED AUTO_INCREMENT,
	nom VARCHAR(45) NOT NULL UNIQUE,
	prixVente FLOAT NOT NULL,
    actif TINYINT NOT NULL,
	idCategorie INT UNSIGNED NOT NULL,
  
	CONSTRAINT PK_Produit PRIMARY KEY (id)
);

-- -----------------------------------------------------
-- Table Commande_Produit
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Commande_Produit (
	idCommande INT UNSIGNED,
	idProduit INT UNSIGNED,
	nbrDeProduit INT UNSIGNED NOT NULL,
    sortiDeCuisine INT UNSIGNED NOT NULL,
  
	CONSTRAINT PK_Commande_Produit PRIMARY KEY (idCommande, idProduit)
);

-- -----------------------------------------------------
-- Table ArticleStock
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS ArticleStock (
	id INT UNSIGNED AUTO_INCREMENT,
	nom VARCHAR(45) NOT NULL UNIQUE,
  
	CONSTRAINT PK_ArticleStock PRIMARY KEY (id)
);

-- -----------------------------------------------------
-- Table LotArticle
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS LotArticle (
	id INT UNSIGNED AUTO_INCREMENT,
	datePeremption DATE NOT NULL,
	nombrePortions INT NOT NULL,
	prixAchat FLOAT NOT NULL,
	idArticleStock INT UNSIGNED NOT NULL,
  
	CONSTRAINT PK_LotArticle PRIMARY KEY (id)
);

-- -----------------------------------------------------
-- Table Log
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Log (
	id INT UNSIGNED AUTO_INCREMENT,
	dateLog DATETIME NOT NULL,
    
	CONSTRAINT PK_Log PRIMARY KEY (id)
);

-- -----------------------------------------------------
-- Table HistoriqueStaff
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS HistoriqueStaff (
	idLog INT UNSIGNED,
	debut DATETIME NOT NULL,
	fin DATETIME,
	idStaff INT UNSIGNED NOT NULL,
  
	CONSTRAINT PK_HistoriqueStaff PRIMARY KEY (idLog)
);

-- -----------------------------------------------------
-- Table Addition
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Addition (
	idLog INT UNSIGNED NOT NULL,
	coutPrixTotal DOUBLE NOT NULL,
	estPaye TINYINT NOT NULL,
 
	CONSTRAINT PK_Addition PRIMARY KEY (idLog)
 );
 
-- -----------------------------------------------------
-- Table EcritureStock
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS EcritureStock (
	idLog INT UNSIGNED NOT NULL,
	idCommande INT UNSIGNED NOT NULL,
  
	CONSTRAINT PK_EcritureStock PRIMARY KEY (idLog)
);

-- -----------------------------------------------------
-- Table ArticleStock_Produit
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS ArticleStock_Produit (
	idArticleStock INT UNSIGNED NOT NULL,
	idProduit INT UNSIGNED NOT NULL,
	nombrePortions INT NOT NULL,
  
	CONSTRAINT PK_ArticleStock_Produit PRIMARY KEY (idArticleStock, idProduit)
);

-- -----------------------------------------------------
-- Table EcritureStock_LotArticle
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS EcritureStock_LotArticle (
	idEcritureStock_Log INT UNSIGNED NOT NULL,
	idLotArticle INT UNSIGNED NOT NULL,
    modifStockNum INT NOT NULL,
  
	CONSTRAINT PK_EcritureStock_LotArticle PRIMARY KEY (idEcritureStock_Log, idLotArticle)
);

  
  
  
-- -----------------------------------------------------
-- Alteration des tables :

	

-- -----------------------------------------------------
-- Alteration table Commande
-- -----------------------------------------------------

CREATE INDEX IDX_FK_Commande_idStaff ON Commande (idStaff);
CREATE INDEX IDX_FK_Commande_idService ON Commande (idService);
CREATE INDEX IDX_FK_Commande_idTableSalle ON Commande (idTableSalle);
CREATE INDEX IDX_FK_Commande_idAddition ON Commande(idAddition);


ALTER TABLE Commande ADD CONSTRAINT FK_Commande_idStaff
	FOREIGN KEY (idStaff) REFERENCES Staff (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE;
    
ALTER TABLE Commande ADD CONSTRAINT FK_Commande_idService
	FOREIGN KEY (idService) REFERENCES Service (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE;
        
ALTER TABLE Commande ADD CONSTRAINT FK_Commande_idTableSalle
    FOREIGN KEY (idTableSalle) REFERENCES TableSalle (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE;

ALTER TABLE Commande ADD CONSTRAINT FK_Commande_idAddition
	FOREIGN KEY (idAddition) REFERENCES Addition (idLog)
		ON DELETE CASCADE
		ON UPDATE CASCADE;


-- -----------------------------------------------------
-- Alteration table Produit
-- -----------------------------------------------------
CREATE INDEX IDX_FK_Produit_idCategorie ON Produit(idCategorie);
  
ALTER TABLE Produit ADD CONSTRAINT FK_Produit_idCategorie
    FOREIGN KEY (idCategorie) REFERENCES EasyService.Categorie(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;


-- -----------------------------------------------------
-- Alteration table Commande_Produit
-- -----------------------------------------------------
CREATE INDEX IDX_FK_Commande_Produit_idCommande ON Commande_Produit(idCommande);
CREATE INDEX IDX_FK_Commande_Produit_idProduit ON Commande_Produit(idProduit);
  
  
ALTER TABLE Commande_Produit ADD CONSTRAINT FK_Commande_Produit_idCommande
    FOREIGN KEY (idCommande) REFERENCES Commande (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE;
    
ALTER TABLE Commande_Produit ADD CONSTRAINT FK_Commande_Produit_idProduit
	FOREIGN KEY (idProduit) REFERENCES Produit (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE;
      
      
-- -----------------------------------------------------
-- Alteration table LotArticle
-- -----------------------------------------------------    
CREATE INDEX IDX_FK_LotArticle_idArticleStock ON LotArticle(idArticleStock);

ALTER TABLE LotArticle ADD CONSTRAINT FK_LotArticle_idArticleStock
    FOREIGN KEY (idArticleStock) REFERENCES EasyService.ArticleStock (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;


-- -----------------------------------------------------
-- Alteration table HistoriqueStaff
-- -----------------------------------------------------  
CREATE INDEX IDX_FK_HistoriqueStaff_idStaff ON HistoriqueStaff (idStaff);
CREATE INDEX IDX_FK_HistoriqueStaff_idLog ON HistoriqueStaff (idLog);
  
ALTER TABLE HistoriqueStaff ADD CONSTRAINT FK_HistoriqueStaff_idStaff
    FOREIGN KEY (idStaff) REFERENCES Staff (id)
		ON DELETE NO ACTION
		ON UPDATE CASCADE;
        
ALTER TABLE HistoriqueStaff ADD CONSTRAINT FK_HistoriqueStaff_idLog
    FOREIGN KEY (idLog) REFERENCES Log (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE;
  
  
 -- -----------------------------------------------------
-- Alteration table Addition
-- ----------------------------------------------------- 
CREATE INDEX IDX_FK_Addition_idLog ON Addition (idLog);

ALTER TABLE Addition ADD CONSTRAINT FK_Addition_idLog
	FOREIGN KEY (idLog) REFERENCES Log (id)
		ON DELETE CASCADE
        ON UPDATE CASCADE;


-- -----------------------------------------------------
-- Alteration table EcritureStock
-- ----------------------------------------------------- 
CREATE INDEX IDX_FK_EcritureStock_idLog ON EcritureStock (idLog);
CREATE INDEX IDX_FK_EcritureStock_idCommande ON EcritureStock (idCommande);
  
  
ALTER TABLE EcritureStock ADD CONSTRAINT FK_EcritureStock_idLog
    FOREIGN KEY (idLog) REFERENCES Log (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE;
        
ALTER TABLE EcritureStock ADD CONSTRAINT FK_EcritureStock_idCommande
    FOREIGN KEY (idCommande) REFERENCES Commande (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE;
    
    

-- -----------------------------------------------------
-- Alteration table ArticleStock_Produit
-- ----------------------------------------------------- 
CREATE INDEX IDX_FK_ArticleStock_Produit_idProduit ON ArticleStock_Produit (idProduit);
CREATE INDEX IDX_FK_ArticleStock_Produit_idArticleStock ON ArticleStock_Produit (idArticleStock);


ALTER TABLE ArticleStock_Produit ADD CONSTRAINT FK_ArticleStock_Produit_idArticleStock
    FOREIGN KEY (idArticleStock) REFERENCES ArticleStock (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE;
        
ALTER TABLE ArticleStock_Produit ADD CONSTRAINT FK_ArticleStock_Produit_idProduit
    FOREIGN KEY (idProduit) REFERENCES EasyService.Produit (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE;

    
-- -----------------------------------------------------
-- Alteration table EcritureStocks_LotArticle
-- ----------------------------------------------------- 
CREATE INDEX IDX_FK_EcritureStock_LotArticle_idLotArticle ON EcritureStock_LotArticle (idLotArticle);
CREATE INDEX IDX_FK_EcritureStock_LotArticle_idEcritureStock ON EcritureStock_LotArticle (idEcritureStock_Log);


ALTER TABLE EcritureStock_LotArticle ADD CONSTRAINT FK_EcritureStock_LotArticle_idEcritureStock
    FOREIGN KEY (idEcritureStock_Log) REFERENCES EasyService.EcritureStock (idLog)
		ON DELETE CASCADE
		ON UPDATE CASCADE;
        
ALTER TABLE EcritureStock_LotArticle ADD CONSTRAINT FK_EcritureStock_LotArticle_idLotArticle
    FOREIGN KEY (idLotArticle) REFERENCES EasyService.LotArticle (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE;
    

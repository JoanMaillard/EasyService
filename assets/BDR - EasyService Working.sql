
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
	id INT NOT NULL AUTO_INCREMENT,
	nom VARCHAR(45) NOT NULL,
	prenom VARCHAR(45) NOT NULL,
	dateNaissance DATE NOT NULL,
  
	CONSTRAINT PK_Staff PRIMARY KEY (id),
	CONSTRAINT UC_Staff_nom_prenom_dateNaissance UNIQUE(nom, prenom, dateNaissance)
  );
-- -----------------------------------------------------
-- Table Service
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Service (
  id INT NOT NULL AUTO_INCREMENT,
  debut TIME NOT NULL,
  fin TIME NOT NULL,
  
  CONSTRAINT PK_Service PRIMARY KEY (id)
);


-- -----------------------------------------------------
-- Table Table
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS EasyService.Table (
	id INT NOT NULL AUTO_INCREMENT,
	ouvertFerme TINYINT NOT NULL,
  
	CONSTRAINT PK_Table PRIMARY KEY (id)
);



-- -----------------------------------------------------
-- Table Commande
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Commande (
	id INT NOT NULL AUTO_INCREMENT,
	nombreCouverts INT UNSIGNED NOT NULL,
	idStaff INT NOT NULL,
	idService INT NOT NULL,
	idTable INT NOT NULL,
    idAddition INT,
  
	CONSTRAINT PK_Commande PRIMARY KEY (id)
  );


-- -----------------------------------------------------
-- Table Categorie
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Categorie (
	id INT NOT NULL AUTO_INCREMENT,
	nom VARCHAR(45) NOT NULL UNIQUE,
  
	CONSTRAINT PK_Categorie PRIMARY KEY (id)
);

-- -----------------------------------------------------
-- Table Produit
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Produit (
	id INT NOT NULL AUTO_INCREMENT,
	nom VARCHAR(45) NOT NULL UNIQUE,
	prixVente FLOAT NOT NULL,
	idCategorie INT NOT NULL,
  
	CONSTRAINT PK_Produit PRIMARY KEY (id)
);

-- -----------------------------------------------------
-- Table Commande_Produit
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Commande_Produit (
	idCommande INT NOT NULL,
	idProduit INT NOT NULL,
	nbrDeProduit INT UNSIGNED NOT NULL,
  
	CONSTRAINT PK_Commande_Produit PRIMARY KEY (idCommande, idProduit)
);


-- -----------------------------------------------------
-- Table EasyService.ArticleStock
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS ArticleStock (
  id INT NOT NULL AUTO_INCREMENT,
  nom VARCHAR(45) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE INDEX nom_UNIQUE (nom ASC) VISIBLE,
  UNIQUE INDEX id_UNIQUE (id ASC) VISIBLE);



-- -----------------------------------------------------
-- Table EasyService.LotArticle
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS LotArticle (
  id INT NOT NULL AUTO_INCREMENT,
  datePeremption DATE NOT NULL,
  nombrePortions INT NOT NULL,
  prixAchat FLOAT NOT NULL,
  idArticleStock INT NOT NULL,
  PRIMARY KEY (id),
  INDEX fk_LotArticle_ArticleStock1_idx (idArticleStock ASC) VISIBLE,
  UNIQUE INDEX id_UNIQUE (id ASC) VISIBLE,
  CONSTRAINT FK_LotArticle_idArticleStock
    FOREIGN KEY (idArticleStock)
    REFERENCES EasyService.ArticleStock (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE);
  


-- -----------------------------------------------------
-- Table Log
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Log (
  id INT NOT NULL AUTO_INCREMENT,
  date DATETIME NOT NULL,
  PRIMARY KEY (id));



-- -----------------------------------------------------
-- Table HistoriqueStaff
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS HistoriqueStaff (
  idLog INT NOT NULL,
  debut DATETIME NOT NULL,
  fin DATETIME NOT NULL,
  idStaff INT NOT NULL,
  PRIMARY KEY (idLog),
  INDEX FK_HistoriqueStaff_idStaff_idx (idStaff ASC) VISIBLE,
  INDEX FK_HistoriqueStaff_idLog_idx (idLog ASC) VISIBLE,
  CONSTRAINT FK_HistoriqueStaff_idStaff
    FOREIGN KEY (idStaff)
    REFERENCES EasyService.Staff (id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT FK_HistoriqueStaff_idLog
    FOREIGN KEY (idLog)
    REFERENCES EasyService.Log (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table Addition
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Addition (
  idLog INT NOT NULL,
  coutPrixTotal DOUBLE NOT NULL,
  estPaye TINYINT NOT NULL,
 
  PRIMARY KEY (idLog),
  
  INDEX FK_Addition_idLog_idx (idLog ASC) VISIBLE,
  
  CONSTRAINT FK_Addition_idLog
    FOREIGN KEY (idLog)
    REFERENCES EasyService.Log (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
 );
-- -----------------------------------------------------
-- Table EasyService.EcritureStock
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS EcritureStock (
  idLog INT NOT NULL,
  idCommande INT NOT NULL,
  PRIMARY KEY (idLog, idCommande),
  INDEX FK_EcritureStock_idLog_idx (idLog ASC) VISIBLE,
  INDEX FK_EcritureStock_idCommande_idx (idCommande ASC) VISIBLE,
  CONSTRAINT FK_EcritureStock_idLog
    FOREIGN KEY (idLog)
    REFERENCES EasyService.Log (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT FK_EcritureStock_idCommande
    FOREIGN KEY (idCommande)
    REFERENCES EasyService.Commande (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE);
 


-- -----------------------------------------------------
-- Table EasyService.ArticleStock_Produit
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS ArticleStock_Produit (
  idArticleStock INT NOT NULL,
  idProduit INT NOT NULL,
  nombrePortions INT NOT NULL,
  
  
  PRIMARY KEY (idArticleStock, idProduit),
  INDEX FK_ArticleStock_Produit_idProduit_idx (idProduit ASC) VISIBLE,
  INDEX fk_ArticleStock_Produit_idArticleStock_idx (idArticleStock ASC) VISIBLE,
  CONSTRAINT FK_ArticleStock_Produit_ArticleStock
    FOREIGN KEY (idArticleStock)
    REFERENCES EasyService.ArticleStock (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT FK_ArticleStock_Produit_Produit
    FOREIGN KEY (idProduit)
    REFERENCES EasyService.Produit (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE);
  


-- -----------------------------------------------------
-- Table EasyService.EcritureStock_LotArticle
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS EcritureStock_LotArticle (
  idEcritureStock_Log INT NOT NULL,
  idEcritureStock_Commande INT NOT NULL,
  idLotArticle INT NOT NULL,
  
  
  PRIMARY KEY (idEcritureStock_Log, idEcritureStock_Commande, idLotArticle),
  INDEX FK_EcritureStocks_LotArticle_idLotArticle_idx (idLotArticle ASC) VISIBLE,
  INDEX FK_EcritureStock_LotArticle_idEcritureStock_idx (idEcritureStock_Log ASC, idEcritureStock_Commande ASC) VISIBLE,
  CONSTRAINT FK_EcritureStock_LotArticle_idEcritureStock
    FOREIGN KEY (idEcritureStock_Log , idEcritureStock_Commande)
    REFERENCES EasyService.EcritureStock (idLog , idCommande)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT FK_EcritureStock_LotArticle_idLotArticle
    FOREIGN KEY (idLotArticle)
    REFERENCES EasyService.LotArticle (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE);
  


-- -----------------------------------------------------
-- Alteration des tables :
-- -----------------------------------------------------

ALTER TABLE Categorie ADD CONSTRAINT UC_Categorie_nom UNIQUE (nom);
	

-- -----------------------------------------------------
-- Alteration table Commande
-- -----------------------------------------------------

-- création d'index.
CREATE INDEX IDX_FK_Commande_idStaff ON Commande (idStaff);
CREATE INDEX IDX_FK_Commande_idService ON Commande (idService);
CREATE INDEX IDX_FK_Commande_idTable ON Commande (idTable);

-- créations de contraintes de clés étrangères.
ALTER TABLE Commande ADD CONSTRAINT FK_Commande_idStaff
	FOREIGN KEY (idStaff) REFERENCES EasyService.Staff (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE;
    
ALTER TABLE Commande ADD CONSTRAINT FK_Commande_idService
	FOREIGN KEY (idService) REFERENCES EasyService.Service (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE;
    
ALTER TABLE Commande ADD CONSTRAINT FK_Commande_idTable
    FOREIGN KEY (idTable) REFERENCES EasyService.Table (id)
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
	FOREIGN KEY (idProduit) REFERENCES EasyService.Produit (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE;
        
-- SET SQL_MODE=@OLD_SQL_MODE;
-- SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
-- SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

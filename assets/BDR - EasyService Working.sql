
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
	ouvert TINYINT NOT NULL,
  
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
    
    
    
    
    
    
-- -----------------------------------------------------
-- Insertions des valeurs dans la table :
-- ----------------------------------------------------- 
USE EasyService;

-- Insertion des membres du staff
INSERT INTO Staff (nom, prenom, dateNaissance, actif) VALUES ('Fontaine', 'Jean', '1960-04-12', TRUE);
INSERT INTO Staff (nom, prenom, dateNaissance, actif) VALUES ('Sartre', 'Jean-Paul', '1955-07-11', TRUE);
INSERT INTO Staff (nom, prenom, dateNaissance, actif) VALUES ('Curie' , 'Marie', '1977-05-11', TRUE);
INSERT INTO Staff (nom, prenom, dateNaissance, actif) VALUES ('Turing', 'Alain', '1954-06-07', TRUE);
INSERT INTO Staff (nom, prenom, dateNaissance, actif) VALUES ('Ramsay', 'Gordon', '1966-11-09', TRUE);
INSERT INTO Staff (nom, prenom, dateNaissance, actif) VALUES ('Oliver', 'Jamie', '1975-05-27', TRUE);
INSERT INTO Staff (nom, prenom, dateNaissance, actif) VALUES ('Keller', 'Thomas', '1955-10-14', TRUE);


-- Insertion de catégorie
INSERT INTO Categorie (nom) VALUES ('Boissons sportives');
INSERT INTO Categorie (nom) VALUES ('Boissons alcoolises');
INSERT INTO Categorie (nom) VALUES ('Boissons minérales');
INSERT INTO Categorie (nom) VALUES ('Apéritifs'); 
INSERT INTO Categorie (nom) VALUES ('Entrees');
INSERT INTO Categorie (nom) VALUES ('Viandes');
INSERT INTO Categorie (nom) VALUES ('Pates');
INSERT INTO Categorie (nom) VALUES ('Vegetarien');
INSERT INTO Categorie (nom) VALUES ('Dessert');


-- Boisson :
INSERT INTO ArticleStock (nom) VALUES ('Coca');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2022-12-01', 50, 3.50, 1);
INSERT INTO ArticleStock (nom) VALUES ('Biere');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2022-12-01', 80, 4.20, 2);
INSERT INTO ArticleStock (nom) VALUES ('Fanta');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2022-12-01', 50, 3.50, 3);
INSERT INTO ArticleStock (nom) VALUES ('Sprite');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2022-12-01', 50, 3.50, 4);


-- Légumes :
INSERT INTO ArticleStock (nom) VALUES ('Tomate');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-12', 200, 0.50, 5);
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-12', 2, 0.50, 5);
INSERT INTO ArticleStock (nom) VALUES ('Salade');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-08', 250, 0.20, 6);
INSERT INTO ArticleStock (nom) VALUES ('Oignon');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-08', 250, 0.20, 7);

-- Viandes :
INSERT INTO ArticleStock (nom) VALUES ('Poulet');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-21', 50, 7.00, 8);
INSERT INTO ArticleStock (nom) VALUES ('Bacon');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-20', 50, 5.00, 9);
INSERT INTO ArticleStock (nom) VALUES ('Boeuf');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-08', 50, 8.00, 10);

-- Pâtes :
INSERT INTO ArticleStock (nom) VALUES ('Penne');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2022-12-01', 50, 3.50, 11);
INSERT INTO ArticleStock (nom) VALUES ('Spaghetti');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2022-12-01', 50, 2.50, 12);
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-12', 50, 2.50, 12);


-- Création des plats et boissons (la carte):

INSERT INTO Produit (nom, prixVente, actif, idCategorie) VALUES ('Bolo', 18.50, TRUE, 7);
INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, nombrePortions) VALUES (5, 1, 2);
INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, nombrePortions) VALUES (10, 1, 1);
INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, nombrePortions) VALUES (12, 1, 1);


INSERT INTO Produit (nom, prixVente, actif, idCategorie) VALUES ('Penne Bacon Ognion', 12.5, TRUE, 7);
INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, nombrePortions) VALUES (5, 2, 2);
INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, nombrePortions) VALUES (10, 2, 1);
INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, nombrePortions) VALUES (11, 2, 1);


INSERT INTO Produit (nom, prixVente, actif, idCategorie) VALUES ('Coca cola', 3.50, TRUE, 1);
INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, nombrePortions) VALUES (1, 3, 1);


INSERT INTO Produit (nom, prixVente, actif, idCategorie) VALUES ('Limonade Sprite', 3.50, TRUE, 1);
INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, nombrePortions) VALUES (4, 4, 1);


-- Insertion des Services :
INSERT INTO Service(debut, fin, actif) VALUES ('05:30:00', '10:30:00', TRUE);
INSERT INTO Service(debut, fin, actif) VALUES ('12:00:00', '14:30:00', TRUE);
INSERT INTO Service(debut, fin, actif) VALUES ('18:45:00', '22:30:00', TRUE);

-- Insertion des Tables :
INSERT INTO TableSalle(ouvert) VALUES (FALSE);
INSERT INTO TableSalle(ouvert) VALUES (FALSE);
INSERT INTO TableSalle(ouvert) VALUES (FALSE);
INSERT INTO TableSalle(ouvert) VALUES (FALSE);
INSERT INTO TableSalle(ouvert) VALUES (FALSE);
INSERT INTO TableSalle(ouvert) VALUES (FALSE);


-- -----------------------------------------------------
-- Procédures stockées :
-- ----------------------------------------------------- 

DELIMITER //

DROP PROCEDURE IF EXISTS AdditionCreer //

CREATE PROCEDURE AdditionCreer (
	IN inIdCommande INT UNSIGNED) 
BEGIN

	DECLARE InsertedId INT UNSIGNED; -- ID du log sur lequel l'addition est basée
    DECLARE Prix FLOAT;				 -- Somme du prix total
    DECLARE AdditionId INT UNSIGNED; -- Identifiant de l'addition potentiellement déjà présente
	
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'unicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
    SELECT idAddition
    INTO additionId
    FROM Commande
    WHERE id = inIdCommande;
    
    IF AdditionNum IS NULL THEN -- Impossible de créer une addition sur une commande qui en a déjà une
		START TRANSACTION;
			INSERT INTO Log (dateLog)
			VALUES (NOW());
			
			SELECT LAST_INSERT_ID()
			INTO InsertedId;
			
			SELECT SUM(prixVente) -- Calcul prix de vente
			INTO Prix
			FROM Produit
			JOIN Commande_Produit ON Commande_Produit.idProduit = Produit.id;
			
			INSERT INTO Addition (idLog, coutPrixTotal, estPaye)
			VALUES (
				InsertedId,
				Prix, 
				FALSE);
			
			UPDATE Commande
			SET idAddition = InsertedId
			WHERE id = inIdCommande;
			
		COMMIT;
	ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erreur: L\'addition existe déjà';
	END IF;
END //

DROP PROCEDURE IF EXISTS AdditionPayer //

CREATE PROCEDURE AdditionPayer (
	IN inIdCommande INT UNSIGNED)
BEGIN
	
    DECLARE TableSalleId INT UNSIGNED DEFAULT 0; -- ID de la table à fermer
    DECLARE AdditionModifieeId INT UNSIGNED DEFAULT 0; -- ID de l'addition à modifier
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'unicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
	START TRANSACTION;
    
		SELECT idAddition
        INTO AdditionModifieeId
        FROM Commande
        WHERE id = inIdCommande;
		
		SELECT idTableSalle
		INTO TableSalleId
		FROM Commande
		WHERE idAddition = AdditionModifieeId;
		
		UPDATE Addition -- Marque l'addition comme payée
		SET estPaye = TRUE
		WHERE idLog = AdditionModifieeId;
		
		UPDATE TableSalle -- Ferme la table une fois que l'addition est payée
		SET ouvert = FALSE
		WHERE id = TableSalleId;
	COMMIT;
END //

DROP PROCEDURE IF EXISTS CategorieAjouter //

CREATE PROCEDURE CategorieAjouter (
	IN inNomCategorie VARCHAR(45))
BEGIN
	INSERT INTO Categorie (nom)
    VALUES (inNomCategorie);
END //

DROP PROCEDURE IF EXISTS CommandeAjouterProduit //

CREATE PROCEDURE CommandeAjouterProduit (
	IN inIdCommande INT UNSIGNED, 
	IN inIdProduit INT UNSIGNED, 
	IN inNbrProduits INT UNSIGNED)
BEGIN

	DECLARE OldNbrProduits INT UNSIGNED; -- le nombre de produits du type spécifié présents précédamment dans la commande
    DECLARE AdditionId INT UNSIGNED; -- Définit l'addition de la commande
    DECLARE ProduitValide TINYINT; -- Définit si le produit est discontinué
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'unicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
    SELECT idAddition
    INTO AdditionId
    FROM Commande
    WHERE id = inIdCommande;
    
    SELECT actif
	INTO ProduitValide
    FROM Produit
    WHERE id = inIdProduit;
    
    IF AdditionId IS NULL THEN -- La commande ne peut pas être créée sur une table ouverte
		IF ProduitValide = TRUE THEN -- On ne peut pas mettre un produit discontinué sur une commande
			START TRANSACTION;
				SELECT nbrDeProduit
				INTO OldNbrProduits
				FROM Commande_Produit
				WHERE idCommande = inIdCommande
					AND idProduit = inIdProduit;
						
				IF OldNbrProduits IS NULL -- Si le produit ne fait pas déjà partie de la commande
				THEN
					INSERT INTO Commande_Produit (idCommande, idProduit, nbrDeProduit, sortiDeCuisine)
					VALUES (inIdCommande, inIdProduit, inNbrProduits, 0);
				ELSE -- Sinon
					UPDATE Commande_Produit
					SET nbrDeProduit = oldNbrProduits + inNbrProduits
					WHERE 
						idCommande = inIdCommande
						AND idProduit = inIdProduit;
				END IF;
			COMMIT;
		ELSE
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erreur: Produit inconnu ou inactif';
        END IF;
	ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erreur: Une commande dont l\'addition existe ne peut pas être modifiée';
    END IF;
END //

DROP PROCEDURE IF EXISTS CommandeCreer //

CREATE PROCEDURE CommandeCreer (
    IN inNumCouvert INT UNSIGNED, 
	IN inIdStaff INT UNSIGNED, 
	IN inIdService INT UNSIGNED, 
	IN inIdTable INT UNSIGNED )
BEGIN
	DECLARE TableOuverte TINYINT; -- Définit l'état d'ouverture de la commande
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'unicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
	START TRANSACTION;
		SELECT ouvert
		INTO TableOuverte 
		FROM tablesalle 
		WHERE id = inIdTable;
		
		IF NOT TableOuverte THEN -- Impossible de créer une commande sur une table ouverte
		
			UPDATE TableSalle
			SET ouvert = TRUE
			WHERE id = inIdTable;
			
			INSERT INTO Commande (nombreCouverts, idStaff, idService, idTableSalle)
			VALUES (inNumCouvert, inIdStaff, inIdService, inIdTable);
		ELSE
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erreur: Table inexistante ou déjà ouverte à la création de commande';
		END IF;
	COMMIT;
END //

DROP PROCEDURE IF EXISTS CommandeRetirerProduit //

CREATE PROCEDURE CommandeRetirerProduit (
	IN inIdCommande INT UNSIGNED,
    IN inIdProduit INT UNSIGNED,
    IN inNbrDeProduit INT UNSIGNED)
BEGIN

	DECLARE DoitToutEnlever TINYINT; -- Definit si le nombre d'unités produit à enlever est le nombre d'unités présent
	DECLARE NumProduitRestant INT UNSIGNED; -- Définit le nombre d'unités produit restants après retrait, s'il y a lieu
    DECLARE AdditionId INT UNSIGNED; -- Définit l'ID de l'addition de la commande
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'unicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
    SELECT idAddition
    INTO AdditionId
    FROM Commande
    WHERE id = inIdCommande;
    
    IF AdditionId IS NULL THEN -- Impossible de modifier une commande qui a une addition
		START TRANSACTION;
			SELECT 
				CASE
					WHEN inNbrDeProduit < nbrDeProduit THEN FALSE
					WHEN inNbrDeProduit = nbrDeProduit THEN TRUE
				END AS enleverTout
			INTO DoitToutEnlever
			FROM Commande_Produit
			WHERE idCommande = inIdCommande
				AND idProduit = inIdProduit;
				
			IF DoitToutEnlever = TRUE -- Si le nombre de produits à enlever de la commande est égal au nombre présent
				THEN -- Enlever complètement le produit
					DELETE FROM Commande_Produit
					WHERE idCommande = inIdCommande
						AND idProduit = inIdProduit;
				ELSE -- Enlever seulement partie des produits
					SELECT (nbrDeProduit - inNbrDeProduit)
					INTO numProduitRestant
					FROM Commande_Produit
					WHERE idCommande = inIdCommande
						AND idProduit = inIdProduit;
					
					
					UPDATE Commande_Produit
					SET nbrDeProduit = NumProduitRestant
					WHERE idCommande = inIdCommande
						AND idProduit = inIdProduit;
			END IF;
		COMMIT;
	ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erreur: Une commande dont l\'addition existe ne peut pas être modifiée';
    END IF;
END //

DROP PROCEDURE IF EXISTS CommandeServirElement //

CREATE PROCEDURE CommandeServirElement (
	IN inIdCommande INT UNSIGNED,
    IN inIdProduit INT UNSIGNED,
    IN inNbrProduits INT UNSIGNED)
BEGIN
	
    DECLARE OldProduitsServis INT UNSIGNED; -- Nombre de produits déjà servis
    DECLARE NumProduitsCommandes INT UNSIGNED; -- Nombre de produits commandés (impossible d'excéder)
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'unicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
	START TRANSACTION;
                
		SELECT sortiDeCuisine, nbrDeProduit
		INTO OldProduitsServis, NumProduitsCommandes
		FROM Commande_Produit
		WHERE idCommande = inIdCommande
			AND idProduit = inIdProduit;
					
			IF OldProduitsServis IS NULL OR OldProduitsServis + inNbrProduits > NumProduitsCommandes
			THEN
				INSERT INTO Commande_Produit (idCommande, idProduit, nbrDeProduit)
				VALUES (inIdCommande, inIdProduit, inNbrProduits);
			ELSE
				UPDATE Commande_Produit
				SET sortiDeCuisine = OldProduitsServis + inNbrProduits
				WHERE 
					idCommande = inIdCommande
					AND idProduit = inIdProduit;
			END IF;
            
    COMMIT;
END //

DROP PROCEDURE IF EXISTS ProduitAjouter //

CREATE PROCEDURE ProduitAjouter (
	IN inNomProduit VARCHAR(45),
    IN inPrixVente FLOAT,
    IN inIdCategorie INT UNSIGNED)
BEGIN
	INSERT INTO Produit (nom, prixVente, idCategorie, actif)
    VALUES (inNomProduit, inPrixVente, inIdCategorie, TRUE);
END //

DROP PROCEDURE IF EXISTS ProduitAjouterArticle //

CREATE PROCEDURE ProduitAjouterArticle ( -- Les produits s'ajoutent au nom pour montrer comment il est possible de résoudre les noms.
	IN inNomProduit VARCHAR(45),		 -- Cependant, il nous a paru important de garder la notation ID pour les autres insertions
    IN inNomArticle VARCHAR(45),         -- afin de garder l'interface qu'une application avec un GUI aurait gardée.
    IN inNumPortions INT UNSIGNED)
BEGIN

	DECLARE CalcArticleId INT UNSIGNED; -- ID calculé de l'article en entrée
    DECLARE CalcProduitId INT UNSIGNED; -- ID calculé du produit en entrée
    
    SELECT id
    INTO CalcArticleId
    FROM ArticleStock
    WHERE nom = inNomArticle;
    
    SELECT id
    INTO CalcProduitId
    FROM Produit
    WHERE nom = inNomProduit;

	INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, nombrePortions)
    VALUES (CalcArticleId, CalcProduitId, inNumPortions);

END //

DROP PROCEDURE IF EXISTS ProduitModifier //

CREATE PROCEDURE ProduitModifier (
	IN inNom VARCHAR(45),
    IN inNouveauNom VARCHAR(45),
    IN inNouveauPrix FLOAT,
    IN inIdCategorie INT UNSIGNED,
    IN inActif TINYINT)
BEGIN
	UPDATE Produit
    SET nom = inNouveauNom, 
		prixVente = inNouveauPrix, 
		idCategorie = inIdCategorie,
        actif = inActif
    WHERE nom = inNom;
END //

DROP PROCEDURE IF EXISTS ProduitRetirerArticle //

CREATE PROCEDURE ProduitRetirerArticle ( -- La seule occurence où nous sortons des données de notre base. Ceci est nécessaire pour permettre
	IN inNomProduit VARCHAR(45), 		 -- la redéfinition ad eternam de produits sans recourir à une composante supplémentaire de clé primaire.
    IN inNomArticle VARCHAR(45))
BEGIN
	
    DECLARE CalcArticleId INT UNSIGNED; -- ID calculé de l'article en entrée
    DECLARE CalcProduitId INT UNSIGNED; -- ID calculé du produit en entrée
    
    SELECT id
    INTO CalcArticleId
    FROM ArticleStock
    WHERE nom = inNomArticle;
    
    SELECT id
    INTO CalcProduitId
    FROM Produit
    WHERE nom = inNomProduit;
    
    DELETE FROM ArticleStock_Produit
    WHERE idArticleStock = CalcArticleId
		AND idProduit = CalcProduitId;
    
END //

DROP PROCEDURE IF EXISTS ServiceAjouter //

CREATE PROCEDURE ServiceAjouter (
	IN inServiceDebut TIME,
    IN inServiceFin TIME)
BEGIN
	
    IF NOT EXISTS ( -- Si aucun service que le nouveau chevaucherait n'existe
		SELECT id
        FROM Service
        WHERE debut <= inServiceDebut AND fin > inServiceDebut
			OR debut >= inServiceDebut AND debut < inServiceFin
    ) AND inServiceDebut < inServiceFin THEN
		INSERT INTO Service (debut, fin, actif)
		VALUES (inServiceDebut, inServiceFin, TRUE);
	ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erreur: Deux services ne peuvent pas se chevaucher';
	END IF;
    
END //

DROP PROCEDURE IF EXISTS ServiceModifier //

CREATE PROCEDURE ServiceModifier (
	IN inIdService INT UNSIGNED,
	IN inNouveauDebut TIME,
    IN inNouveauFin TIME,
    IN inActif TINYINT)
BEGIN
	
    IF NOT EXISTS ( -- Si aucun service que la nouvelle définition du courant chevaucherait n'existe
			SELECT id
			FROM Service
			WHERE (debut <= inNouveauDebut AND fin > inNouveauDebut
				OR debut >= inNouvauDebut AND debut < inNouveauFin)
				AND id != inIdService
		) AND inNouveauDebut < inNouveauFin THEN
			UPDATE Service
            SET debut = inNouveauDebut, fin = inNouveauFin, actif = inActif
            WHERE id = inIdService;
	ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erreur: Deux services ne peuvent pas se chevaucher';
	END IF;

END //

DROP PROCEDURE IF EXISTS StaffAjouter //

CREATE PROCEDURE StaffAjouter (
	IN inNom VARCHAR(45),
    IN inPrenom VARCHAR(45),
    IN inDateNaissance DATE)
BEGIN
	
	INSERT INTO Staff (nom, prenom, dateNaissance, actif)
    VALUES (inNom, inPrenom, inDateNaissance, TRUE);
    
END //

DROP PROCEDURE IF EXISTS StaffEntrer //

CREATE PROCEDURE StaffEntrer ( -- Crée un log d'entrée d'un membre du staff à l'instant NOW.
	IN inIdStaff INT UNSIGNED)
BEGIN

	DECLARE InsertedId INT UNSIGNED; -- ID du log créé
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'unicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
    IF NOT EXISTS (
		SELECT id
		FROM HistoriqueStaff
		WHERE idStaff = inIdStaff
			AND fin IS NULL) 
	THEN
		START TRANSACTION;
			INSERT INTO Log (dateLog)
			VALUES (NOW());
			
			SELECT LAST_INSERT_ID()
			INTO InsertedId;
			
			INSERT INTO historiqueStaff (idLog, debut, idStaff)
			VALUES (InsertedId, NOW(), inIdStaff);
		COMMIT;
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erreur: Impossible d\'ouvrir deux entrées en service sans sortir de la précédente.';
	END IF;
END //

DROP PROCEDURE IF EXISTS StaffRenvoyer //

CREATE PROCEDURE StaffRenvoyer (
	IN inIdStaff INT UNSIGNED)
BEGIN
	
    UPDATE Staff
    SET actif = FALSE
    WHERE id = inIdStaff;
    
END //

DROP PROCEDURE IF EXISTS StaffSortir //

CREATE PROCEDURE StaffSortir ( -- Modifie le dernier log d'entrée d'un membre du staff à l'instant NOW.
	IN inIdStaff INT UNSIGNED)
BEGIN
	DECLARE LigneAFinirId INT UNSIGNED; -- L'identifiant du log d'entrée en question
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'unicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
	START TRANSACTION;
		SELECT idLog
		INTO LigneAFinirId
		FROM HistoriqueStaff
		WHERE idStaff = inIdStaff
			AND fin IS NULL;
			
		UPDATE HistoriqueStaff
		SET fin = NOW()
		WHERE idLog = LigneAFinirId;
	COMMIT;    
END //

DROP PROCEDURE IF EXISTS StockDeduireProduit //

CREATE PROCEDURE StockDeduireProduit (
	IN inIdProduit INT UNSIGNED,
    IN inNumProduit INT UNSIGNED, -- Nombre de fois qu'il faut déduire le produit
    IN inIdEcritureStockLog INT UNSIGNED)
BEGIN
	
    DECLARE ForLoopCounter INT UNSIGNED DEFAULT 0;
    DECLARE MaxForLoop INT UNSIGNED DEFAULT 0; -- Contiendra le nombre d'articles du stock du produit
    DECLARE LotActuelId INT UNSIGNED;
    DECLARE LotActuelDeductible INT UNSIGNED;
    DECLARE ArticleActuelDeProduit INT UNSIGNED;
    DECLARE ArticleActuelDeProduitNumRestant INT UNSIGNED;
    DECLARE ArticleActuelDeProduitQtyPerUnit INT UNSIGNED;
    
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
	START TRANSACTION;
	
    SELECT COUNT(idArticleStock)
    INTO MaxForLoop
    FROM ArticleStock_Produit
    WHERE idProduit = inIdProduit;
    
    REPEAT -- Probablement plus élégant avec un curseur. Itère à travers tous les articles du produit sélectionné.
		
        
        SELECT idArticleStock, nombrePortions
		INTO ArticleActuelDeProduit, ArticleActuelDeProduitQtyPerUnit
        FROM ArticleStock_Produit
        WHERE idProduit = inIdProduit
        ORDER BY idArticleStock
        LIMIT forLoopCounter, 1;
        
        SET ArticleActuelDeProduitNumRestant = inNumProduit * ArticleActuelDeProduitQtyPerUnit;
        
		REPEAT -- Une fois qu'on a défini quel élément (article) du produit on retire du stock, ainsi que le nombre d'entre eux par unité du produit:
        
			SELECT id, nombrePortions -- Récupère le nombre maximal retirable du lot actuel
			INTO LotActuelId, LotActuelDeductible
			FROM LotArticle
			WHERE idArticleStock = ArticleActuelDeProduit
				AND nombrePortions > 0
			ORDER BY datePeremption ASC,
					nombrePortions ASC
			LIMIT 0, 1;
			
			IF LotActuelDeductible < inNumProduit * ArticleActuelDeProduitQtyPerUnit
				THEN -- S'il n'est pas possible de retirer tous les éléments restants du seul lot courant, 
					UPDATE LotArticle -- retirer ce qu'on peut et choisir un nouveau lot
					SET nombrePortions = 0
					WHERE id = LotActuelId;
					
					INSERT INTO EcritureStock_LotArticle (idEcritureStock_Log, idLotArticle, modifStockNum)
					VALUES (inIdEcritureStockLog,  LotActuelId, LotActuelDeductible);
					
					SET ArticleActuelDeProduitNumRestant = ArticleActuelDeProduitNumRestant - LotActuelDeductible;
				ELSE -- Si c'est possible, retirer ce qu'il faut retirer et sortir
					UPDATE LotArticle
					SET nombrePortions = LotActuelDeductible - ArticleActuelDeProduitNumRestant
					WHERE id = LotActuelId;
					
					INSERT INTO EcritureStock_LotArticle(idEcritureStock_Log, idLotArticle, modifStockNum)
					VALUES (inIdEcritureStockLog, LotActuelId, ArticleActuelDeProduitNumRestant);
					
					SET ArticleActuelDeProduitNumRestant = 0;
			END IF;
        
        
        UNTIL ArticleActuelDeProduitNumRestant = 0
		END REPEAT;
        
        SET ForLoopCounter = ForLoopCounter + 1;
        
        UNTIL ForLoopCounter = MaxForLoop
	END REPEAT;
    
    COMMIT;
END //

DROP PROCEDURE IF EXISTS StockInserer //

CREATE PROCEDURE StockInserer (
	IN inIdArticle INT UNSIGNED,
    IN inNumArticle INT UNSIGNED,
    IN inDatePeremption DATETIME,
    IN inPrixAchat FLOAT)
BEGIN
    
    INSERT INTO LotArticle (idArticleStock, nombrePortions, datePeremption, prixAchat)
    VALUES (inIdArticle, inNumArticle, inDatePeremption, inPrixAchat);
    
END //

DROP PROCEDURE IF EXISTS StockSortirSelonCommande //

CREATE PROCEDURE StockSortirSelonCommande(
	IN inIdCommande INT UNSIGNED)
BEGIN
	
    DECLARE InsertedId INT UNSIGNED; -- ID du log créé
    DECLARE ForLoopTracker INT UNSIGNED DEFAULT 0; -- Trackeur de la boucle
    DECLARE MaximumLoopTracker INT UNSIGNED DEFAULT 0; -- Définition de la sortie de la boucle
    DECLARE ProduitCourantId INT; -- Variable de travail pour le type de produits en cours de traitement
    DECLARE ProduitCourantNbr INT; -- Variable de travail pour le nombre de produits du type en traitement
    
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'unicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
	START TRANSACTION;
		INSERT INTO Log (dateLog)
		VALUES (NOW());
		
		SELECT LAST_INSERT_ID()
		INTO InsertedId;
		
		INSERT INTO EcritureStock (idLog, idCommande)
		VALUES (InsertedId, inIdCommande);
        
        SELECT COUNT(idProduit)
        INTO MaximumLoopTracker
        FROM Commande_Produit
        WHERE idCommande = inIdCommande;
        
        REPEAT -- Probablement plus propre avec un curseur. Itère à travers les éléments de la commande et les soustrait du stock.
        
			SELECT idProduit, nbrDeProduit
			INTO ProduitCourantId, ProduitCourantNbr
			FROM Commande_Produit
			WHERE idCommande = inIdCommande
            ORDER BY idProduit ASC
            LIMIT ForLoopTracker, 1;
			
			CALL StockDeduireProduit(ProduitCourantId, ProduitCourantNbr, InsertedId);
            
            SET ForLoopTracker = ForLoopTracker + 1;
            
            UNTIL ForLoopTracker >= MaximumLoopTracker
        END REPEAT;
	COMMIT;
END //

DROP PROCEDURE IF EXISTS TableAjouter //

CREATE PROCEDURE TableAjouter ()
BEGIN

	INSERT INTO TableSalle (ouvert)
    VALUES (FALSE);

END //

DELIMITER ;





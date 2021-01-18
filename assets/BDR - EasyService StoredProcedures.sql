USE EasyService;
DELIMITER //

DROP PROCEDURE IF EXISTS SelectAllLotsParArticle;
DELIMITER //
CREATE PROCEDURE SelectAllLotsParArticle (
IN inArticle VARCHAR(45))
BEGIN
	SELECT LotArticle.id, nombrePortions
	FROM LotArticle
	JOIN ArticleStock ON LotArticle.idArticleStock = ArticleStock.id
	WHERE ArticleStock.nom = inArticle;
END // 

DROP PROCEDURE IF EXISTS SelectAllTablesFermees;
DELIMITER //
CREATE PROCEDURE SelectAllTablesFermees ()
BEGIN
	SELECT id 
    FROM TableSalle 
    WHERE ouvertFerme = FALSE;
END //


DROP PROCEDURE IF EXISTS CommandeAjouter;
DELIMITER //
CREATE PROCEDURE CommandeAjouter (
    IN inNumCouvert INT UNSIGNED, 
	IN inIdStaff INT UNSIGNED, 
	IN inIdService INT UNSIGNED, 
	IN inIdTable INT UNSIGNED )
BEGIN
	DECLARE Valide INT;
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
	START TRANSACTION;
		SELECT ouvertFerme 
		INTO Valide 
		FROM tablesalle 
		WHERE id = idTableSalle;
		
		IF Valide > 0 THEN
		
			UPDATE TableSalle
			SET ouvertFerme = TRUE
			WHERE id = inIdTable;
			
			INSERT INTO Commande (nombreCouverts, idStaff, idService, idTableSalle)
			VALUES (inNumCouvert, inIdStaff, inIdService, inIdTable);
			
		END IF;
	COMMIT;
END //

DROP PROCEDURE IF EXISTS CommandeAjouterProduit;
DELIMITER //
CREATE PROCEDURE CommandeAjouterProduit (
	IN inIdCommande INT UNSIGNED, 
	IN inIdProduit INT UNSIGNED, 
	IN inNbrProduits INT UNSIGNED)
BEGIN

	DECLARE OldNbrProduits INT UNSIGNED;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
	START TRANSACTION;
		SELECT nbrDeProduit
			INTO OldNbrProduits
			FROM Commande_Produit
			WHERE idCommande = inIdCommande
				AND idProduit = inIdProduit;
				
		IF OldNbrProduits IS NULL
		THEN
			INSERT INTO Commande_Produit (idCommande, idProduit, nbrDeProduit)
			VALUES (inIdCommande, inIdProduit, inNbrProduits);
		ELSE
			UPDATE Commande_Produit
			SET nbrDeProduit = oldNbrProduits + inNbrProduits
			WHERE 
				idCommande = inIdCommande
				AND idProduit = inIdProduit;
		END IF;
    COMMIT;
END //

DROP PROCEDURE IF EXISTS CommandeRetirerProduit;
DELIMITER //
CREATE PROCEDURE CommandeRetirerProduit (
	IN inIdCommande INT UNSIGNED,
    IN inIdProduit INT UNSIGNED,
    IN inNbrDeProduit INT UNSIGNED)
BEGIN

	DECLARE MustRemoveAll TINYINT;
	DECLARE NumProduitRestant INT UNSIGNED;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
    START TRANSACTION;
		SELECT 
			CASE
				WHEN inNbrProduit < nbrDeProduit THEN FALSE
				WHEN inNbrProduit = nbrDeProduit THEN TRUE
			END AS mustRemove
		INTO MustRemoveAll
		FROM Commande_Produit
		WHERE idCommande = inIdCommande
			AND idProduit = inIdProduit;
			
		IF MustRemoveAll = TRUE
			THEN
				DELETE FROM Commande_Produit
				WHERE idCommande = inIdCommande
					AND idProduit = inIdProduit;
			ELSE
				SELECT (nbrDeProduit - inNbrProduit)
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
END //

DROP PROCEDURE IF EXISTS AdditionCreer;
DELIMITER //
CREATE PROCEDURE AdditionCreer (
	IN inIdCommande INT UNSIGNED) 
BEGIN

	DECLARE InsertedId INT UNSIGNED;
    DECLARE Prix FLOAT;
	
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
	START TRANSACTION;
		INSERT INTO Log (dateLog)
		VALUES (NOW());
		
		SELECT LAST_INSERT_ID()
		INTO InsertedId;
		
		SELECT SUM(prixVente) 
		INTO Prix
		FROM Produit
		JOIN Commande_Produit ON Commande_Produit.idProduit = Produit.id;
		
		INSERT INTO Addition (idLog, coutPrixTotal, estPaye, idCommande)
		VALUES (
			InsertedId,
			Prix, 
			FALSE,
			inIdCommande);
	COMMIT;
END //

DROP PROCEDURE IF EXISTS AdditionPayer;
DELIMITER //
CREATE PROCEDURE AdditionPayer (
	IN inIdAddition INT UNSIGNED)
BEGIN
	
    DECLARE TableSalleId INT UNSIGNED;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
	START TRANSACTION;
		SELECT idTableSalle
		INTO TableSalleId
		FROM Commande
		WHERE idAddition = inIdAddition;
		
		UPDATE addition
		SET estPaye = TRUE
		WHERE idLog = inIdAddition;
		
		UPDATE tablesalle
		SET ouvertFerme = FALSE
		WHERE id = TableSalleId;
	COMMIT;
END //

DROP PROCEDURE IF EXISTS StockInserer;
DELIMITER //
CREATE PROCEDURE StockInserer(
	IN inIdArticle INT UNSIGNED,
    IN inNumArticle INT UNSIGNED,
    IN inDatePeremption DATETIME,
    IN inPrixAchat FLOAT)
BEGIN
    
    INSERT INTO LotArticle (idArticleStock, nombrePortions, datePeremption, prixAchat)
    VALUES (inIdArticle, inNumArticle, inDatePeremption, inPrixAchat);
    
END //

DROP PROCEDURE IF EXISTS StockSortirSelonCommande;
DELIMITER //
CREATE PROCEDURE StockSortirSelonCommande(
	IN inIdCommande INT UNSIGNED)
BEGIN
	
    DECLARE InsertedId INT UNSIGNED;
    DECLARE ForLoopTracker INT UNSIGNED DEFAULT 0;
    DECLARE MaximumLoopTracker INT UNSIGNED DEFAULT 0;
    DECLARE IdProduitCourant INT;
    DECLARE NumProduitCourant INT;
    
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
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
        
        REPEAT
        
			SET ForLoopTracker = ForLoopTracker + 1;
            
			SELECT 
				NTH_VALUE(idProduit, ForLoopTracker) OVER (ORDER BY idProduit ASC), 
				NTH_VALUE(nbrDeProduit, ForLoopTracker) OVER (ORDER BY idProduit ASC) 
			INTO idProduitCourant, numProduitCourant
			FROM Commande_Produit
			WHERE idCommande = inIdCommande;
			
			CALL StockDeduireProduits(IdArticleCourant, NumArticleCourant);
            
            UNTIL ForLoopTracker >= MaximumLoopTracker
        END REPEAT;
	COMMIT;
END //

DROP PROCEDURE IF EXISTS StockDeduireProduit;
DELIMITER//
CREATE PROCEDURE StockDeduireProduit (
	IN inIdProduit INT UNSIGNED,
    IN inNumProduit INT UNSIGNED)
BEGIN
	
    DECLARE ForLoopCounter INT UNSIGNED DEFAULT 0;
    DECLARE CurrentBatchDeductible INT UNSIGNED;
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
	START TRANSACTION;
	
    REPEAT
		SET ForLoopCounter = ForLoopCounter + 1;
        
		SELECT 
    
    COMMIT;
END //

DROP PROCEDURE IF EXISTS CommandeServirElement;
DELIMITER //
CREATE PROCEDURE CommandeServirElement (
	IN inIdCommande INT UNSIGNED,
    IN inIdProduit INT UNSIGNED,
    IN inNbrProduits INT UNSIGNED)
BEGIN
	
    DECLARE OldProduitsServis INT UNSIGNED;
    DECLARE NumProduitsCommandes INT UNSIGNED;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
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
					
			IF OldNbrProduits IS NULL OR OldNbrProduits + inNbrProduits > NumProduitsCommandes
			THEN
				INSERT INTO Commande_Produit (idCommande, idProduit, nbrDeProduit)
				VALUES (inIdCommande, inIdProduit, inNbrProduits);
			ELSE
				UPDATE Commande_Produit
				SET sortiDeCuisine = oldNbrProduits + inNbrProduits
				WHERE 
					idCommande = inIdCommande
					AND idProduit = inIdProduit;
			END IF;
            
    COMMIT;
END //
    
DROP PROCEDURE IF EXISTS ServiceCommencer;
DELIMITER //
CREATE PROCEDURE ServiceCommencer(
	IN inIdStaff INT UNSIGNED)
BEGIN

	DECLARE InsertedId INT UNSIGNED;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
	START TRANSACTION;
		INSERT INTO Log (dateLog)
		VALUES (NOW());
		
		SELECT LAST_INSERT_ID()
		INTO InsertedId;
		
		INSERT INTO historiqueStaff (idLog, debut, idStaff)
		VALUES (InsertedId, NOW(), inIdStaff);
	COMMIT;
END //

DROP PROCEDURE IF EXISTS ServiceTerminer;
DELIMITER //
CREATE PROCEDURE ServiceTerminer (
	IN inIdStaff INT UNSIGNED)
BEGIN
	DECLARE IdToClose INT UNSIGNED;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
	START TRANSACTION;
		SELECT idLog
		INTO IdToClose
		FROM HistoriqueStaff
		WHERE idStaff = inIdStaff
			AND fin IS NULL;
			
		UPDATE HistoriqueStaff
		SET fin = NOW()
		WHERE idLog = IdToClose;
	COMMIT;    
END //






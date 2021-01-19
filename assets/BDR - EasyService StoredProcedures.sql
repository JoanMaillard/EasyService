USE EasyService;
DELIMITER //

/* DROP PROCEDURE IF EXISTS SelectAllLotsParArticle;
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
END // */


DROP PROCEDURE IF EXISTS CommandeAjouter;
DELIMITER //
CREATE PROCEDURE CommandeAjouter (
    IN inNumCouvert INT UNSIGNED, 
	IN inIdStaff INT UNSIGNED, 
	IN inIdService INT UNSIGNED, 
	IN inIdTable INT UNSIGNED )
BEGIN
	DECLARE Invalide TINYINT;
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
	START TRANSACTION;
		SELECT ouvertFerme 
		INTO Invalide 
		FROM tablesalle 
		WHERE id = inIdTable;
		
		IF NOT Invalide THEN
		
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
    DECLARE AdditionNum INT UNSIGNED;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
    SELECT idAddition
    INTO AdditionNum
    FROM Commande
    WHERE id = inIdCommande;
    
    IF AdditionNum IS NULL THEN
		START TRANSACTION;
			SELECT nbrDeProduit
				INTO OldNbrProduits
				FROM Commande_Produit
				WHERE idCommande = inIdCommande
					AND idProduit = inIdProduit;
					
			IF OldNbrProduits IS NULL
			THEN
				INSERT INTO Commande_Produit (idCommande, idProduit, nbrDeProduit, sortiDeCuisine)
				VALUES (inIdCommande, inIdProduit, inNbrProduits, 0);
			ELSE
				UPDATE Commande_Produit
				SET nbrDeProduit = oldNbrProduits + inNbrProduits
				WHERE 
					idCommande = inIdCommande
					AND idProduit = inIdProduit;
			END IF;
		COMMIT;
    END IF;
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
    DECLARE AdditionNum INT UNSIGNED;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
    SELECT idAddition
    INTO AdditionNum
    FROM Commande
    WHERE id = inIdCommande;
    
    IF AdditionNum IS NULL THEN
		START TRANSACTION;
			SELECT 
				CASE
					WHEN inNbrDeProduit < nbrDeProduit THEN FALSE
					WHEN inNbrDeProduit = nbrDeProduit THEN TRUE
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
    END IF;
END //

DROP PROCEDURE IF EXISTS AdditionCreer;
DELIMITER //
CREATE PROCEDURE AdditionCreer (
	IN inIdCommande INT UNSIGNED) 
BEGIN

	DECLARE InsertedId INT UNSIGNED;
    DECLARE Prix FLOAT;
    DECLARE AdditionNum INT UNSIGNED;
	
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    SELECT idAddition
    INTO additionNum
    FROM Commande
    WHERE id = inIdCommande;
    
    IF AdditionNum IS NULL THEN
		START TRANSACTION;
			INSERT INTO Log (dateLog)
			VALUES (NOW());
			
			SELECT LAST_INSERT_ID()
			INTO InsertedId;
			
			SELECT SUM(prixVente) 
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
	END IF;
END //

DROP PROCEDURE IF EXISTS AdditionPayer;
DELIMITER //
CREATE PROCEDURE AdditionPayer (
	IN inIdCommande INT UNSIGNED)
BEGIN
	
    DECLARE TableSalleId INT UNSIGNED DEFAULT 0;
    DECLARE IdUpdatedAddition INT UNSIGNED DEFAULT 0;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- garantit l'atomicité de la transaction
    BEGIN
        ROLLBACK; 
        RESIGNAL;
    END;
    
	START TRANSACTION;
    
		SELECT idAddition
        INTO IdUpdatedAddition
        FROM Commande
        WHERE id = inIdCommande;
		
		SELECT idTableSalle
		INTO TableSalleId
		FROM Commande
		WHERE idAddition = IdUpdatedAddition;
		
		UPDATE Addition
		SET estPaye = TRUE
		WHERE idLog = IdUpdatedAddition;
		
		UPDATE TableSalle
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
        
			SELECT idProduit, nbrDeProduit
			INTO idProduitCourant, numProduitCourant
			FROM Commande_Produit
			WHERE idCommande = inIdCommande
            ORDER BY idProduit ASC
            LIMIT 0, 1;
			
			CALL StockDeduireProduit(IdProduitCourant, NumProduitCourant, InsertedId);
            
            SET ForLoopTracker = ForLoopTracker + 1;
            
            UNTIL ForLoopTracker >= MaximumLoopTracker
        END REPEAT;
	COMMIT;
END //

DROP PROCEDURE IF EXISTS StockDeduireProduit;
DELIMITER //
CREATE PROCEDURE StockDeduireProduit (
	IN inIdProduit INT UNSIGNED,
    IN inNumProduit INT UNSIGNED,
    IN inIdEcritureStockLog INT UNSIGNED)
BEGIN
	
    DECLARE ForLoopCounter INT UNSIGNED DEFAULT 0;
    DECLARE MaxForLoop INT UNSIGNED DEFAULT 0;
    DECLARE CurrentBatchId INT UNSIGNED;
    DECLARE CurrentBatchDeductible INT UNSIGNED;
    DECLARE CurrentArticleDeProduit INT UNSIGNED;
    DECLARE CurrentArticleDeProduitNumRestant INT UNSIGNED;
    DECLARE CurrentArticleDeProduitQtyPerUnit INT UNSIGNED;
    
    
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
    
    REPEAT
		
        
        SELECT idArticleStock, nombrePortions
		INTO CurrentArticleDeProduit, CurrentArticleDeProduitQtyPerUnit
        FROM ArticleStock_Produit
        WHERE idProduit = inIdProduit
        ORDER BY idArticleStock
        LIMIT forLoopCounter, 1;
        
        SET CurrentArticleDeProduitNumRestant = inNumProduit * CurrentArticleDeProduitQtyPerUnit;
        
		REPEAT -- une fois qu'on a défini de quel élément du produit on parle et combien il en faut par unité
        
        SELECT id, nombrePortions -- get current amount of oldest, least full batch of determined 
		INTO CurrentBatchId, CurrentBatchDeductible
        FROM LotArticle
        WHERE idArticleStock = CurrentArticleDeProduit
			AND nombrePortions > 0
		ORDER BY datePeremption ASC,
                nombrePortions ASC
		LIMIT 0, 1;
		
        IF CurrentBatchDeductible < inNumProduit * CurrentArticleDeProduitQtyPerUnit
			THEN -- if can't pull the whole quota from one batch
				UPDATE LotArticle
				SET nombrePortions = 0
                WHERE id = CurrentBatchId;
                
                INSERT INTO EcritureStock_LotArticle (idEcritureStock_Log, idLotArticle, modifStockNum)
                VALUES (inIdEcritureStockLog,  CurrentBatchId, CurrentBatchDeductible);
                
                SET CurrentArticleDeProduitNumRestant = CurrentArticleDeProduitNumRestant - CurrentBatchDeductible;
			ELSE -- if you can
				UPDATE LotArticle
                SET nombrePortions = CurrentBatchDeductible - CurrentArticleDeProduitNumRestant
                WHERE id = CurrentBatchId;
                
                INSERT INTO EcritureStock_LotArticle(idEcritureStock_Log, idLotArticle, modifStockNum)
                VALUES (inIdEcritureStockLog, CurrentBatchId, CurrentArticleDeProduitNumRestant);
                
                SET CurrentArticleDeProduitNumRestant = 0;
		END IF;
        
        
        UNTIL CurrentArticleDeProduitNumRestant = 0
		END REPEAT;
        
        SET ForLoopCounter = ForLoopCounter + 1;
        
        UNTIL ForLoopCounter = MaxForLoop
	END REPEAT;
    
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

DROP PROCEDURE IF EXISTS ProduitAjouter;
DELIMITER // 
CREATE PROCEDURE ProduitAjouter (
	IN inNomProduit VARCHAR(45),
    IN inPrixVente FLOAT,
    IN inIdCategorie INT UNSIGNED)
BEGIN
	INSERT INTO Produit (nom, prixVente, idCategorie)
    VALUES (inNomProduit, inPrixVente, inIdCategorie);
END //

DROP PROCEDURE IF EXISTS ProduitModifier;
DELIMITER //
CREATE PROCEDURE ProduitModifier (
	IN inNom VARCHAR(45),
    IN inNouveauNom VARCHAR(45),
    IN inNouveauPrix FLOAT,
    IN inIdCategorie INT UNSIGNED)
BEGIN
	UPDATE Produit
    SET nom = inNouveauNom, 
		prixVente = inNouveauPrix, 
		idCategorie = inIdCategorie
    WHERE nom = inNom;
END //

DROP PROCEDURE IF EXISTS ProduitAjouterArticle;
DELIMITER //
CREATE PROCEDURE ProduitAjouterArticle (
	IN inNomProduit VARCHAR(45),
    IN inNomArticle VARCHAR(45),
    IN inNumPortions INT UNSIGNED)
BEGIN

	DECLARE IdCalcArticle INT UNSIGNED;
    DECLARE IdCalcProduit INT UNSIGNED;
    
    SELECT id
    INTO IdCalcArticle
    FROM ArticleStock
    WHERE nom = inNomArticle;
    
    SELECT id
    INTO IdCalcProduit
    FROM Produit
    WHERE nom = inNomProduit;

	INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, idNombrePortions)
    VALUES (IdCalcArticle, IdCalcProduit, inNumPortions);

END //

DROP PROCEDURE IF EXISTS ProduitRetirerArticle;
DELIMITER //
CREATE PROCEDURE ProduitRetirerArticle (
	IN inNomProduit VARCHAR(45),
    IN inNomArticle VARCHAR(45))
BEGIN
	
    DECLARE IdCalcArticle INT UNSIGNED;
    DECLARE IdCalcProduit INT UNSIGNED;
    
    SELECT id
    INTO IdCalcArticle
    FROM ArticleStock
    WHERE nom = inNomArticle;
    
    SELECT id
    INTO IdCalcProduit
    FROM Produit
    WHERE nom = inNomProduit;
    
    DELETE FROM ArticleStock_Produit
    WHERE idArticleStock = IdCalcArticle
		AND idProduit = IdCalcProduit;
    
END //

DROP PROCEDURE IF EXISTS CategorieAjouter 
DELIMITER // 
CREATE PROCEDURE CategorieAjouter (
	IN inNomCategorie VARCHAR(45))
BEGIN
	INSERT INTO Categorie (nom)
    VALUES (idNomCategorie);
END //

DROP PROCEDURE IF EXISTS StaffAjouter;
DELIMITER //
CREATE PROCEDURE StaffAjouter (
	IN inNom VARCHAR(45),
    IN inPrenom VARCHAR(45),
    IN inDateNaissance DATE)
BEGIN
	
	INSERT INTO Staff (nom, prenom, dateNaissance)
    VALUES (inNom, inPrenom, inDateNaissance);
    
END //

DROP PROCEDURE IF EXISTS TableAjouter;
DELIMITER //
CREATE PROCEDURE TableAjouter ()
BEGIN

	INSERT INTO TableSalle (ouvertFerme)
    VALUES (FALSE);

END //

DROP PROCEDURE IF EXISTS ServiceAjouter
DELIMITER //
CREATE PROCEDURE ServiceAjouter (
	IN inServiceDebut TIME,
    IN inServiceFin TIME)
BEGIN
	
    IF NOT EXISTS (
		SELECT id
        FROM Service
        WHERE debut < inServiceDebut AND fin > inServiceDebut
			OR debut > inServiceDebut AND debut < inServiceFin
    ) AND inServiceDebut < inServiceFin THEN
		INSERT INTO Service (debut, fin)
		VALUES (inServiceDebut, inServiceFin);
	END IF;
    
END //

DROP PROCEDURE IF EXISTS ServiceModifier
DELIMITER //
CREATE PROCEDURE ServiceModifier (
	IN inIdService INT UNSIGNED,
	IN inNouveauDebut TIME,
    IN inNouveauFin TIME)
BEGIN
	
    IF NOT EXISTS (
		SELECT id
        FROM Service
        WHERE (debut < inNouveauDebut AND fin > inNouveauDebut
			OR debut > inNouvauDebut AND debut < inNouveauFin)
            AND id != idIdService
		) AND inNouveauDebut < inNouveauFin THEN
			UPDATE Service
            SET debut = inNouveauDebut, fin = inNouveauFin
            WHERE id = inIdService;
	END IF;

END //






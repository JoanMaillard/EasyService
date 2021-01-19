
USE EasyService;
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


    



USE EasyService;
DELIMITER //

DROP PROCEDURE IF EXISTS SelectAllLotsParArticle;
DELIMITER //
CREATE PROCEDURE SelectAllLotsParArticle (
IN Article VARCHAR(45))
BEGIN
	SELECT lotarticle.id, nombrePortions
	FROM lotarticle
	JOIN articlestock ON lotarticle.idArticleStock = articlestock.id
	WHERE articlestock.nom = Article;
END // 

DROP PROCEDURE IF EXISTS SelectAllTablesFermees;
DELIMITER //
CREATE PROCEDURE SelectAllTablesFermees ()
BEGIN
	SELECT id 
    FROM tableSalle 
    WHERE ouvertFerme = FALSE;
END //


DROP PROCEDURE IF EXISTS AjouterCommande; DELIMITER //
DELIMITER //
CREATE PROCEDURE AjouterCommande (
    IN inNumCouvert INT UNSIGNED, 
	IN inIdStaff INT UNSIGNED, 
	IN inIdService INT UNSIGNED, 
	IN inIdTable INT UNSIGNED )
BEGIN
	DECLARE Valide INT;
    
    SELECT ouvertFerme 
    INTO Valide 
    FROM tablesalle 
    WHERE id = idTableSalle;
    
	IF Valide > 0 THEN
    
		UPDATE tablesalle
        SET ouvertFerme = TRUE
        WHERE id = inIdTable;
        
		INSERT INTO commande (nombreCouverts, idStaff, idService, idTableSalle)
		VALUES (inNumCouvert, inIdStaff, inIdService, inIdTable);
        
	END IF;
END //

-- TODO: add trigger to commande_produit to replace behavior with adding nbrProduits to current count if product already in command
DROP PROCEDURE IF EXISTS AjouterProduitSurCommande;
DELIMITER //
CREATE PROCEDURE AjouterProduitSurCommande (
	IN inIdCommande INT UNSIGNED, 
	IN inIdProduit INT UNSIGNED, 
	IN inNbrProduits INT UNSIGNED)
BEGIN
    INSERT INTO commande_produit (idCommande, idProduit, nbrDeProduit)
    VALUES (inIdCommande, inIdProduit, inNbrProduits);
END //

DROP PROCEDURE IF EXISTS CreerAddition;
DELIMITER //
CREATE PROCEDURE CreerAddition (
	IN inIdCommande INT UNSIGNED) 
BEGIN

	DECLARE InsertedId INT UNSIGNED;
    DECLARE Prix FLOAT;

	INSERT INTO Log (dateLog)
    VALUES (NOW());
    
    SELECT LAST_INSERT_ID()
    INTO InsertedId;
    
	SELECT SUM(prixVente) 
    INTO Prix
	FROM produit
	JOIN commande_produit ON commande_produit.idProduit = produit.id;
    
    INSERT INTO addition (idLog, coutPrixTotal, estPaye, idCommande)
    VALUES (
		InsertedId,
        Prix, 
		FALSE,
        inIdCommande);
END //

DROP PROCEDURE IF EXISTS PayerAddition;
DELIMITER //
CREATE PROCEDURE PayerAddition (
	IN inIdAddition INT UNSIGNED)
BEGIN
	
    DECLARE TableSalleId INT UNSIGNED;
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
END //

DROP PROCEDURE IF EXISTS InsererDansStock;
DELIMITER //
CREATE PROCEDURE InsererDansStock(
	IN ArticleId INT UNSIGNED,
    IN ArticleNum INT UNSIGNED,
    IN DatePeremption DATETIME,
    IN PrixAchat FLOAT)
BEGIN
    
    INSERT INTO LotArticle (idArticleStock, nombrePortions, datePeremption, prixAchat)
    VALUES (ArticleId, ArticleNum, DatePeremption, PrixAchat)
    
END //
    
    
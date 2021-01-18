USE EasyService;
DELIMITER //

DROP PROCEDURE IF EXISTS SelectAllLotsParArticle;
-- DELIMITER //
CREATE PROCEDURE SelectAllLotsParArticle (IN Article VARCHAR(45))
BEGIN
	SELECT lotarticle.id, nombrePortions
	FROM lotarticle
	JOIN articlestock ON lotarticle.idArticleStock = articlestock.id
	WHERE articlestock.nom = Article;
END // 

DROP PROCEDURE IF EXISTS SelectAllTablesFermees;
-- DELIMITER //
CREATE PROCEDURE SelectAllTablesFermees ()
BEGIN
	SELECT id 
    FROM tableSalle 
    WHERE ouvertFerme = FALSE;
END //

DROP PROCEDURE IF EXISTS toto;
-- DELIMITER //
CREATE PROCEDURE toto (
	IN idIdTable INT )
BEGIN
	UPDATE tablesalle
	SET ouvertFerme = 1
	WHERE id = inIdTable;
END //

-- TODO: add trigger to open table if not opened already
DROP PROCEDURE IF EXISTS AjouterCommande; DELIMITER //
DELIMITER //
CREATE PROCEDURE AjouterCommande (
    IN inNumCouvert INT UNSIGNED, 
	IN inIdStaff INT UNSIGNED, 
	IN inIdService INT UNSIGNED, 
	IN inIdTable INT UNSIGNED )
BEGIN
	DECLARE Validze INT;
    
    SELECT ouvertFerme 
    INTO Validze 
    FROM tablesalle 
    WHERE id = idTable;
    
	IF Validze > 0 THEN
    
		UPDATE tablesalle
        SET ouvertFerme = 1
        WHERE id = inIdTable;
        
		INSERT INTO commande (nombreCouverts, idStaff, idService, idTable)
		VALUES (inNumCouvert, inIdStaff, inIdService, inIdTable);
        
	END IF;
END //

-- TODO: add trigger to commande_produit to replace behavior with adding nbrProduits to current count if product already in command
DROP PROCEDURE IF EXISTS AjouterProduitSurCommande;
DELIMITER //
CREATE PROCEDURE AjouterProduitSurCommande (inIdCommande INT UNSIGNED, inIdProduit INT UNSIGNED, inNbrProduits INT UNSIGNED)
BEGIN
    INSERT INTO commande_produit (idCommande, idProduit, nbrDeProduit)
    VALUES (inIdCommande, inIdProduit, inNbrProduits);
END //

DROP PROCEDURE IF EXISTS CreerAddition;
DELIMITER //
CREATE PROCEDURE CreerAddition (inIdCommande INT UNSIGNED) 
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
CREATE PROCEDURE PayerAddition (inIdAddition INT UNSIGNED)
BEGIN
	UPDATE addition
    SET estPaye = TRUE
    WHERE idLog = inIdAddition;
    
    UPDATE tablesalle
    SET ouvertFerme = FALSE
    WHERE 
END //
    
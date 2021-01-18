USE EasyService;

-- ========================= STOCKS ==========================
-- ----------------- STOCKS AVEC PEREMPTION ------------------
CREATE VIEW StockAvecPeremption
AS
	SELECT A.nom, L.nombrePortions, L.datePeremption FROM ArticleStock AS A, LotArticle AS L
    WHERE A.id = L.idArticleStock;

-- ========================== MENU ==========================
-- -----------------------  BOISSONS ------------------------
CREATE VIEW BoissonsMinerales 
AS
	SELECT ArticleStock.nom, Produit.prixVente FROM ArticleStock
    INNER JOIN ArticleStock_Produit INNER JOIN Produit ON ArticleStock_Produit.idProduit = Produit.id
		ON ArticleStock.id = ArticleStock_Produit.idArticleStock 
    WHERE Produit.idCategorie = 0; -- je suppose que id SoftDrink = 0
    
CREATE VIEW BoissonsAlcoolisees
AS
	SELECT ArticleStock.nom, Produit.prixVente FROM ArticleStock
    INNER JOIN ArticleStock_Produit INNER JOIN Produit ON ArticleStock_Produit.idProduit = Produit.id
		ON ArticleStock.id = ArticleStock_Produit.idArticleStock 
    WHERE Produit.idCategorie = 1; -- je suppose que id SoftDrink = 1
    
CREATE VIEW BoissonsChaudes
AS
	SELECT ArticleStock.nom, Produit.prixVente FROM ArticleStock
    INNER JOIN ArticleStock_Produit INNER JOIN Produit ON ArticleStock_Produit.idProduit = Produit.id
		ON ArticleStock.id = ArticleStock_Produit.idArticleStock 
    WHERE Produit.idCategorie = 2; -- je suppose que id hotDrink = 2
    
CREATE VIEW Boissons
AS
	SELECT ArticleStock.nom, Produit.prixVente FROM ArticleStock
    INNER JOIN ArticleStock_Produit INNER JOIN Produit ON ArticleStock_Produit.idProduit = Produit.id
		ON ArticleStock.id = ArticleStock_Produit.idArticleStock 
    WHERE Produit.idCategorie BETWEEN 0 AND 2; 

-- ------------------------- VIANDES ------------------------
CREATE VIEW Boeuf
AS
	SELECT nom, prixVente FROM Produit WHERE idCategorie = 3; -- raison pour 3 comme au dessus
    
CREATE VIEW Poulet
AS
	SELECT nom, prixVente FROM Produit WHERE idCategorie = 4; -- je repete plus xD
    
CREATE VIEW Porc
AS
	SELECT nom, prixVente FROM Produit WHERE idCategorie = 5; 
    
CREATE VIEW FruitsDeMer
AS
	SELECT nom, prixVente FROM Produit WHERE idCategorie = 6;
    
CREATE VIEW Viandes
AS
	SELECT nom, prixVente FROM Produit 
    WHERE idCategorie BETWEEN 3 AND 6;
    
-- ----------------------- VEGETARIEN -----------------------
CREATE VIEW Vegetarien
AS
	SELECT nom, prixVente FROM Produit WHERE idCategorie = 7;
    

CREATE VIEW Plats
AS
	SELECT nom, prixVente FROM Produit 
    WHERE idCategorie BETWEEN 3 AND 7;

-- ------------------------- DESSERT -------------------------
CREATE VIEW Desserts
AS
	SELECT nom, prixVente FROM Produit WHERE idCategorie = 8;

-- -------------------------- MENU ---------------------------
CREATE VIEW Menu
AS 
	SELECT nom, prixVente FROM Produit 
    WHERE idCategorie BETWEEN 0 AND 8;
-- ===========================================================

-- ======================== COMMANDE =========================
-- ------------------- PRODUITS NON PAYES --------------------
CREATE VIEW ProduitNonPayes
AS
	SELECT T.id, Produit.nom FROM EasyService.Table AS T
    INNER JOIN Commande 
		INNER JOIN Commande_Produit
			INNER JOIN Produit 
			ON Produit.id = Commande_Produit.idProduit
		ON Commande.id = Commande_Produit.idCommande
	ON T.id = Commande.idTable
    WHERE T.ouvertFerme = 1; 
    
-- ----------- LISTE DE TABLES SERVIEs PAR STAFFS ------------
CREATE VIEW TablesParStaffs
AS
	SELECT T.id, Staff.nom, Staff.prenom FROM EasyService.Table AS T
    INNER JOIN Commande 
		INNER JOIN Staff 
        ON Staff.id = Commande.idStaff
	ON T.id = Commande.idTable;

-- LISTE DE STAFFS PAR SERVICE (AVEC PRECISION DE L'HEURE DE TRAVAIL)
CREATE VIEW StaffsParServices 
AS
	SELECT St.nom, St.prenom, HistoriqueStaff.debut AS arrivee, HistoriqueStaff.fin AS depart, Service.debut, Service.fin FROM Staff AS St
    INNER JOIN Commande 
		INNER JOIN Service 
        ON Service.id = Commande.idService
	ON St.id = Commande.idStaff
    INNER JOIN HistoriqueStaff 
    ON St.id = HistoriqueStaff.idStaff
    WHERE HistoriqueStaff.fin BETWEEN Service.debut AND Service.fin OR HistoriqueStaff.debut BETWEEN Service.debut AND Service.fin;
    

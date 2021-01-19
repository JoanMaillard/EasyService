USE EasyService;


-- ================= VUE - MAITRE DE SALLE ===================
-- -------------------- TABLES OUVERTES ----------------------
CREATE VIEW vSalleTablesOuvertes
AS
	SELECT TableSalle.id, Produit.nom FROM TableSalle 
    INNER JOIN Commande 
		INNER JOIN Commande_Produit
			INNER JOIN Produit 
			ON Produit.id = Commande_Produit.idProduit
		ON Commande.id = Commande_Produit.idCommande
	ON TableSalle.id = Commande.idTableSalle
    WHERE TableSalle.ouvert = 1; 
    
-- ----------- LISTE DE TABLES SERVIES PAR STAFFS ------------
CREATE VIEW vSalleTablesParStaffs
AS
	SELECT TableSalle.id, Staff.nom, Staff.prenom FROM TableSalle
    INNER JOIN Commande 
		INNER JOIN Staff 
        ON Staff.id = Commande.idStaff
	ON TableSalle.id = Commande.idTableSalle;

-- LISTE DE STAFFS PAR SERVICE (AVEC PRECISION DE L'HEURE DE TRAVAIL)
CREATE VIEW vSalleStaffsParServices 
AS
	SELECT 
		Staff.nom, 
        Staff.prenom, 
        HistoriqueStaff.debut AS arrivee, 
        HistoriqueStaff.fin AS depart, 
        Service.debut, 
        Service.fin 
	FROM Staff
		INNER JOIN Commande 
			INNER JOIN Service 
			ON Service.id = Commande.idService
		ON Staff.id = Commande.idStaff
		INNER JOIN HistoriqueStaff 
		ON Staff.id = HistoriqueStaff.idStaff
    WHERE HistoriqueStaff.fin BETWEEN Service.debut AND Service.fin OR HistoriqueStaff.debut BETWEEN Service.debut AND Service.fin;	

-- ================= VUE - CHEF CUISINIER ===================
CREATE VIEW vCuisineStock
AS
	SELECT 
		ArticleStock.nom, 
		LotArticle.nombrePortions, 
        LotArticle.datePeremption 
	FROM ArticleStock, LotArticle
    WHERE ArticleStock.id = LotArticle.idArticleStock;
    
CREATE VIEW vCommande
AS
	SELECT 
		Commande.id, 
		Produit.nom 
	FROM Commande
		INNER JOIN Commande_Produit
			INNER JOIN Produit 
			ON Produit.id = Commande_Produit.idProduit
		ON Commande.id = Commande_Produit.idCommande;
    
CREATE VIEW vProduit
AS
	SELECT
		Produit.nom AS nomProduit,
        ArticleStock.nom AS nomArticle
	FROM Produit
		INNER JOIN ArticleStock_Produit
			INNER JOIN ArticleStock
            ON ArticleStock_Produit.idArticleStock = ArticleStock.id
		ON Produit.id = ArticleStock_Produit.idProduit
		

		
		
    

USE EasyService;


-- ================= VUE - MAITRE DE SALLE ===================
-- -------------------- TABLES OUVERTES ----------------------
CREATE VIEW vSalleTablesOuvertes
AS
	SELECT T.id, Produit.nom FROM TableSalle AS T
    INNER JOIN Commande 
		INNER JOIN Commande_Produit
			INNER JOIN Produit 
			ON Produit.id = Commande_Produit.idProduit
		ON Commande.id = Commande_Produit.idCommande
	ON T.id = Commande.idTableSalle
    WHERE T.ouvertFerme = 1; 
    
-- ----------- LISTE DE TABLES SERVIES PAR STAFFS ------------
CREATE VIEW vSalleTablesParStaffs
AS
	SELECT T.id, Staff.nom, Staff.prenom FROM TableSalle AS T
    INNER JOIN Commande 
		INNER JOIN Staff 
        ON Staff.id = Commande.idStaff
	ON T.id = Commande.idTableSalle;

-- LISTE DE STAFFS PAR SERVICE (AVEC PRECISION DE L'HEURE DE TRAVAIL)
CREATE VIEW vSalleStaffsParServices 
AS
	SELECT St.nom, St.prenom, HistoriqueStaff.debut AS arrivee, HistoriqueStaff.fin AS depart, Service.debut, Service.fin FROM Staff AS St
    INNER JOIN Commande 
		INNER JOIN Service 
        ON Service.id = Commande.idService
	ON St.id = Commande.idStaff
    INNER JOIN HistoriqueStaff 
    ON St.id = HistoriqueStaff.idStaff
    WHERE HistoriqueStaff.fin BETWEEN Service.debut AND Service.fin OR HistoriqueStaff.debut BETWEEN Service.debut AND Service.fin;	

-- ================= VUE - CHEF CUISINIER ===================
CREATE VIEW vCuisineStock
AS
	SELECT 
		A.nom, 
		L.nombrePortions, 
        L.datePeremption 
	FROM ArticleStock AS A, LotArticle AS L
    WHERE A.id = L.idArticleStock;

		
		
    

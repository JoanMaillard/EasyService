USE EasyService;

-- Test git

-- Insertion des membres du staff
INSERT INTO Staff (nom, prenom, dateNaissance) VALUES ('Fontaine', 'Jean', '1960-04-12');
INSERT INTO Staff (nom, prenom, dateNaissance) VALUES ('Sartre', 'Jean-Paul', '1955-07-11');
INSERT INTO Staff (nom, prenom, dateNaissance) VALUES ('Curie' , 'Marie', '1977-05-11');
INSERT INTO Staff (nom, prenom, dateNaissance) VALUES ('Turing', 'Alain', '1954-06-07');
INSERT INTO Staff (nom, prenom, dateNaissance) VALUES ('Ramsay', 'Gordon', '1966-11-09');
INSERT INTO Staff (nom, prenom, dateNaissance) VALUES ('Oliver', 'Jamie', '1975-05-27');
INSERT INTO Staff (nom, prenom, dateNaissance) VALUES ('Keller', 'Thomas', '1955-10-14');



-- Boisson
INSERT INTO ArticleStock (nom) VALUES ('Coca');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2022-12-01', 50, 3.50, 1);
INSERT INTO ArticleStock (nom) VALUES ('biere');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2022-12-01', 80, 4.20, 2);
INSERT INTO ArticleStock (nom) VALUES ('Fanta');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2022-12-01', 50, 3.50, 3);
INSERT INTO ArticleStock (nom) VALUES ('Sprite');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2022-12-01', 50, 3.50, 4);

-- Légumes
INSERT INTO ArticleStock (nom) VALUES ('Tomtate');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-12', 200, 0.50, 5);
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-12', 2, 0.50, 5);
INSERT INTO ArticleStock (nom) VALUES ('Salade');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-08', 250, 0.20, 6);
INSERT INTO ArticleStock (nom) VALUES ('Oignon');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-08', 250, 0.20, 7);

-- Viandes
INSERT INTO ArticleStock (nom) VALUES ('Poulet');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-21', 50, 7.00, 8);
INSERT INTO ArticleStock (nom) VALUES ('Bacon');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-20', 50, 5.00, 9);
INSERT INTO ArticleStock (nom) VALUES ('Boeuf');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-08', 50, 8.00, 10);

-- Pâtes
INSERT INTO ArticleStock (nom) VALUES ('Penne');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2022-12-01', 50, 3.50, 11);
INSERT INTO ArticleStock (nom) VALUES ('Spaghetti');
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2022-12-01', 50, 2.50, 12);
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2021-02-12', 50, 2.50, 12);


-- Création des plats :
INSERT INTO Produit (nom, prixVente, idCategorie) VALUES ('Bolo', 18.5, 7);
INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, nombrePortions) VALUES (5, 1, 2);
INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, nombrePortions) VALUES (10, 1, 1);
INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, nombrePortions) VALUES (12, 1, 1);

INSERT INTO Produit (nom, prixVente, idCategorie) VALUES ('Penne Bacon Ognion', 12.5, 7);
INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, nombrePortions) VALUES (5, 2, 2);
INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, nombrePortions) VALUES (10, 2, 1);
INSERT INTO ArticleStock_Produit (idArticleStock, idProduit, nombrePortions) VALUES (11, 2, 1);



INSERT INTO Service(debut, fin) VALUES ('05:30:00', '10:30:00');
INSERT INTO Service(debut, fin) VALUES ('12:00:00', '14:30:00');
INSERT INTO Service(debut, fin) VALUES ('18:45:00', '22:30:00');

INSERT INTO TableSalle(ouvertFerme) VALUES (FALSE);
INSERT INTO TableSalle(ouvertFerme) VALUES (FALSE);
INSERT INTO TableSalle(ouvertFerme) VALUES (FALSE);
INSERT INTO TableSalle(ouvertFerme) VALUES (FALSE);
INSERT INTO TableSalle(ouvertFerme) VALUES (FALSE);
INSERT INTO TableSalle(ouvertFerme) VALUES (FALSE);


INSERT INTO Categorie (nom) VALUES ('Boissons sportives');
INSERT INTO Categorie (nom) VALUES ('Boissons alcoolises');
INSERT INTO Categorie (nom) VALUES ('Boissons minérales');
INSERT INTO Categorie (nom) VALUES ('Apéritifs'); 
INSERT INTO Categorie (nom) VALUES ('Entrees');
INSERT INTO Categorie (nom) VALUES ('Viandes');
INSERT INTO Categorie (nom) VALUES ('Pates');
INSERT INTO Categorie (nom) VALUES ('Vegetarien');
INSERT INTO Categorie (nom) VALUES ('Dessert');



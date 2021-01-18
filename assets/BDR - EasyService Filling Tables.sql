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
INSERT INTO LotArticle(datePeremption, nombrePortions, prixAchat, idArticleStock) VALUES ('2020-12-01', 50, 2.50, 1);

INSERT INTO ArticleStock (nom) VALUES ('biere');
INSERT INTO ArticleStock (nom) VALUES ('Fanta');
INSERT INTO ArticleStock (nom) VALUES ('Sprite');

-- Légumes
INSERT INTO ArticleStock (nom) VALUES ('Tomtate');
INSERT INTO ArticleStock (nom) VALUES ('Salade');
INSERT INTO ArticleStock (nom) VALUES ('Oignon');
INSERT INTO ArticleStock (nom) VALUES ('Ail');
INSERT INTO ArticleStock (nom) VALUES ('Courgette');
INSERT INTO ArticleStock (nom) VALUES ('Carotte');
INSERT INTO ArticleStock (nom) VALUES ('Aubergine');

-- Viandes
INSERT INTO ArticleStock (nom) VALUES ('Poulet');
INSERT INTO ArticleStock (nom) VALUES ('Bacon');
INSERT INTO ArticleStock (nom) VALUES ('Boeuf');
INSERT INTO ArticleStock (nom) VALUES ('Cheval');

-- Pâtes
INSERT INTO ArticleStock (nom) VALUES ('Penne');
INSERT INTO ArticleStock (nom) VALUES ('Spaghetti');
INSERT INTO ArticleStock (nom) VALUES ('Ravioli');


INSERT INTO Service(debut, fin) VALUES ('05:30:00', '10:30:00');
INSERT INTO Service(debut, fin) VALUES ('12:00:00', '14:30:00');
INSERT INTO Service(debut, fin) VALUES ('18:45:00', '22:30:00');



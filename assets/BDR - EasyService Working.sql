
-- -----------------------------------------------------
-- Schema EasyService
-- -----------------------------------------------------
-- Projet BDR EasyService Groupe 6.
DROP SCHEMA IF EXISTS `EasyService` ;

-- -----------------------------------------------------
-- Schema EasyService
--
-- Projet BDR EasyService Groupe 6.
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `EasyService` DEFAULT CHARACTER SET utf8mb4 ;
USE `EasyService` ;

-- -----------------------------------------------------
-- Table `EasyService`.`Staff`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EasyService`.`Staff` (
  `id` INT NOT NULL,
  `nom` VARCHAR(45) NOT NULL,
  `prenom` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE);



-- -----------------------------------------------------
-- Table `EasyService`.`Service`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EasyService`.`Service` (
  `id` INT NOT NULL,
  `debut` DATETIME NOT NULL,
  `fin` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE);



-- -----------------------------------------------------
-- Table `EasyService`.`Table`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EasyService`.`Table` (
  `id` INT NOT NULL,
  `ouvertFerme` TINYINT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE);



-- -----------------------------------------------------
-- Table `EasyService`.`Commande`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EasyService`.`Commande` (
  `id` INT NOT NULL,
  `nombreCouverts` INT UNSIGNED NOT NULL,
  `idStaff` INT NOT NULL,
  `idService` INT NOT NULL,
  `idTable` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `FK_Commande_idStaff_idx` (`idStaff` ASC) VISIBLE,
  INDEX `FK_Commande_idService_idx` (`idService` ASC) VISIBLE,
  INDEX `FK_Commande_idTable_idx` (`idTable` ASC) VISIBLE,
  CONSTRAINT `FK_Commande_idStaff`
    FOREIGN KEY (`idStaff`)
    REFERENCES `EasyService`.`Staff` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_Commande_idService`
    FOREIGN KEY (`idService`)
    REFERENCES `EasyService`.`Service` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_Commande_idTable`
    FOREIGN KEY (`idTable`)
    REFERENCES `EasyService`.`Table` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table `EasyService`.`Categorie`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EasyService`.`Categorie` (
  `id` INT NOT NULL,
  `nom` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `nom_UNIQUE` (`nom` ASC) VISIBLE,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE);


-- -----------------------------------------------------
-- Table `EasyService`.`Produit`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EasyService`.`Produit` (
  `id` INT NOT NULL,
  `nom` VARCHAR(45) NOT NULL,
  `prixVente` FLOAT NOT NULL,
  `idCategorie` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Produit_Categorie1_idx` (`idCategorie` ASC) VISIBLE,
  UNIQUE INDEX `nom_UNIQUE` (`nom` ASC) VISIBLE,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  CONSTRAINT `FK_Produit_idCategorie`
    FOREIGN KEY (`idCategorie`)
    REFERENCES `EasyService`.`Categorie` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);
  


-- -----------------------------------------------------
-- Table `EasyService`.`Commande_Produit`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EasyService`.`Commande_Produit` (
  `idCommande` INT NOT NULL,
  `idProduit` INT NOT NULL,
  `nbrDeProduit` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`idCommande`, `idProduit`),
  INDEX `FK_Commande_Produit_idCommande_idx` (`idCommande` ASC) INVISIBLE,
  INDEX `FK_Commande_Produit_idProduit_idx` (`idProduit` ASC) INVISIBLE,
  CONSTRAINT `FK_Commande_Produit_idCommande`
    FOREIGN KEY (`idCommande`)
    REFERENCES `EasyService`.`Commande` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_Commande_Produit_idProduit`
    FOREIGN KEY (`idProduit`)
    REFERENCES `EasyService`.`Produit` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table `EasyService`.`ArticleStock`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EasyService`.`ArticleStock` (
  `id` INT NOT NULL,
  `nom` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `nom_UNIQUE` (`nom` ASC) VISIBLE,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE);



-- -----------------------------------------------------
-- Table `EasyService`.`LotArticle`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EasyService`.`LotArticle` (
  `id` INT NOT NULL,
  `datePeremption` DATE NOT NULL,
  `nombrePortions` INT NOT NULL,
  `prixAchat` FLOAT NOT NULL,
  `idArticleStock` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_LotArticle_ArticleStock1_idx` (`idArticleStock` ASC) VISIBLE,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  CONSTRAINT `FK_LotArticle_idArticleStock`
    FOREIGN KEY (`idArticleStock`)
    REFERENCES `EasyService`.`ArticleStock` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);
  


-- -----------------------------------------------------
-- Table `EasyService`.`Log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EasyService`.`Log` (
  `id` INT NOT NULL,
  `date` DATETIME NOT NULL,
  PRIMARY KEY (`id`));



-- -----------------------------------------------------
-- Table `EasyService`.`HistoriqueStaff`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EasyService`.`HistoriqueStaff` (
  `idLog` INT NOT NULL,
  `debut` DATETIME NOT NULL,
  `fin` DATETIME NOT NULL,
  `idStaff` INT NOT NULL,
  PRIMARY KEY (`idLog`),
  INDEX `FK_HistoriqueStaff_idStaff_idx` (`idStaff` ASC) VISIBLE,
  INDEX `FK_HistoriqueStaff_idLog_idx` (`idLog` ASC) VISIBLE,
  CONSTRAINT `FK_HistoriqueStaff_idStaff`
    FOREIGN KEY (`idStaff`)
    REFERENCES `EasyService`.`Staff` (`id`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `FK_HistoriqueStaff_idLog`
    FOREIGN KEY (`idLog`)
    REFERENCES `EasyService`.`Log` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table `EasyService`.`Addition`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EasyService`.`Addition` (
  `idLog` INT NOT NULL,
  `coutPrixTotal` DOUBLE NOT NULL,
  `estPaye` TINYINT NOT NULL,
  `Commande_id` INT NOT NULL,
  PRIMARY KEY (`idLog`),
  INDEX `FK_Addition_idLog_idx` (`idLog` ASC) VISIBLE,
  INDEX `fk_Addition_Commande1_idx` (`Commande_id` ASC) VISIBLE,
  CONSTRAINT `FK_Addition_idLog`
    FOREIGN KEY (`idLog`)
    REFERENCES `EasyService`.`Log` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Addition_Commande1`
    FOREIGN KEY (`Commande_id`)
    REFERENCES `EasyService`.`Commande` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
  
-- -----------------------------------------------------
-- Table `EasyService`.`EcritureStock`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EasyService`.`EcritureStock` (
  `idLog` INT NOT NULL,
  `idCommande` INT NOT NULL,
  PRIMARY KEY (`idLog`, `idCommande`),
  INDEX `FK_EcritureStock_idLog_idx` (`idLog` ASC) VISIBLE,
  INDEX `FK_EcritureStock_idCommande_idx` (`idCommande` ASC) VISIBLE,
  CONSTRAINT `FK_EcritureStock_idLog`
    FOREIGN KEY (`idLog`)
    REFERENCES `EasyService`.`Log` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_EcritureStock_idCommande`
    FOREIGN KEY (`idCommande`)
    REFERENCES `EasyService`.`Commande` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);
 


-- -----------------------------------------------------
-- Table `EasyService`.`ArticleStock_Produit`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EasyService`.`ArticleStock_Produit` (
  `idArticleStock` INT NOT NULL,
  `idProduit` INT NOT NULL,
  PRIMARY KEY (`idArticleStock`, `idProduit`),
  INDEX `FK_ArticleStock_Produit_idProduit_idx` (`idProduit` ASC) VISIBLE,
  INDEX `fk_ArticleStock_Produit_idArticleStock_idx` (`idArticleStock` ASC) VISIBLE,
  CONSTRAINT `FK_ArticleStock_Produit_ArticleStock`
    FOREIGN KEY (`idArticleStock`)
    REFERENCES `EasyService`.`ArticleStock` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_ArticleStock_Produit_Produit`
    FOREIGN KEY (`idProduit`)
    REFERENCES `EasyService`.`Produit` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);
  


-- -----------------------------------------------------
-- Table `EasyService`.`EcritureStock_LotArticle`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EasyService`.`EcritureStock_LotArticle` (
  `idEcritureStock_Log` INT NOT NULL,
  `idEcritureStock_Commande` INT NOT NULL,
  `idLotArticle` INT NOT NULL,
  PRIMARY KEY (`idEcritureStock_Log`, `idEcritureStock_Commande`, `idLotArticle`),
  INDEX `FK_EcritureStocks_LotArticle_idLotArticle_idx` (`idLotArticle` ASC) VISIBLE,
  INDEX `FK_EcritureStock_LotArticle_idEcritureStock_idx` (`idEcritureStock_Log` ASC, `idEcritureStock_Commande` ASC) VISIBLE,
  CONSTRAINT `FK_EcritureStock_LotArticle_idEcritureStock`
    FOREIGN KEY (`idEcritureStock_Log` , `idEcritureStock_Commande`)
    REFERENCES `EasyService`.`EcritureStock` (`idLog` , `idCommande`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_EcritureStock_LotArticle_idLotArticle`
    FOREIGN KEY (`idLotArticle`)
    REFERENCES `EasyService`.`LotArticle` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);
  


-- SET SQL_MODE=@OLD_SQL_MODE;
-- SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
-- SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

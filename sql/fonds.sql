# ************************************************************
# Sequel Ace SQL dump
# Version 3021
#
# https://sequel-ace.com/
# https://github.com/Sequel-Ace/Sequel-Ace
#
# Host: 127.0.0.1 (MySQL 5.5.51-log)
# Database: vatican_mss
# Generation Time: 2021-03-12 00:17:07 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
SET NAMES utf8mb4;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE='NO_AUTO_VALUE_ON_ZERO', SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table fonds
# ------------------------------------------------------------

DROP TABLE IF EXISTS `fonds`;

CREATE TABLE `fonds` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(64) CHARACTER SET utf8mb4 DEFAULT NULL,
  `full_name` varchar(128) CHARACTER SET utf8mb4 DEFAULT NULL,
  `header_text` text CHARACTER SET utf8mb4,
  `image_filename` varchar(128) DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `code_idx` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `fonds` WRITE;
/*!40000 ALTER TABLE `fonds` DISABLE KEYS */;

INSERT INTO `fonds` (`id`, `code`, `full_name`, `header_text`, `image_filename`, `enabled`)
VALUES
	(1,'Arch.Cap.S.Pietro','Archivio del Capitolo di S. Pietro',NULL,NULL,1),
	(2,'Autogr.Paolo.VI','Autografi Paolo VI ',NULL,NULL,1),
	(3,'Barb.gr','Barberiniani Greci/Greek',NULL,NULL,1),
	(4,'Barb.lat','Barberiniani Latini/Latin',NULL,NULL,1),
	(5,'Barb.or','Barberiniani Orientali/Asian',NULL,NULL,1),
	(6,'Bonc','Bonbompagni Ludovisi',NULL,NULL,1),
	(7,'Borg.Carte.naut','Borgiani Carte Nautiche',NULL,NULL,1),
	(8,'Borg.ar','Borgiani Arabi/Arabic',NULL,NULL,1),
	(9,'Borg.arm','Borgiani Armeni/Armenian',NULL,NULL,1),
	(10,'Borg.cin','Borgiani Cinesi/Chinese',NULL,NULL,1),
	(11,'Borg.copt','Borgiani Copti/Coptic',NULL,NULL,1),
	(12,'Borg.ebr','Borgiani Ebraici/Hebrew',NULL,NULL,1),
	(13,'Borg.eg','Borgiani Egiziani/Egyptian',NULL,NULL,1),
	(14,'Borg.et','Borgiani Ethiopici/Ethiopic',NULL,NULL,1),
	(15,'Borg.gr','Borgiani Greci/Greek',NULL,NULL,1),
	(16,'Borg.ill','Borgiani Illirici/Balkan',NULL,NULL,1),
	(17,'Borg.ind','Borgiani Indiani/Indian',NULL,NULL,1),
	(18,'Borg.isl','Borgiani Islandesi/Iceland',NULL,NULL,1),
	(19,'Borg.lat','Borgiani Latini/Latin',NULL,NULL,1),
	(20,'Borg.mess','Borgiani Messicani/Latin America',NULL,NULL,1),
	(21,'Borg.pers','Borgiani Persiani/Persian',NULL,NULL,1),
	(22,'Borg.siam','Borgiani Siamesi/Thai',NULL,NULL,1),
	(23,'Borg.sir','Borgiani Siriaci/Syriac',NULL,NULL,1),
	(24,'Borg.tonch','Borgiani Tonchinesi/Vietnamese',NULL,NULL,1),
	(25,'Borg.turc','Borgiani Turchi/Turkish',NULL,NULL,1),
	(26,'Borgh','Borghesiani',NULL,NULL,1),
	(27,'Capp.Giulia','Cappella Giulla',NULL,NULL,1),
	(28,'Capp.Sist','Cappella Sistina',NULL,NULL,1),
	(29,'Capp.Sist.Diari','Cappella Sistina Diari',NULL,NULL,1),
	(30,'Cappon','Capponiani',NULL,NULL,1),
	(31,'Carte.Stefani','Carte Stefani',NULL,NULL,1),
	(32,'Carte.d\'Abbadie','Carte d\'Abbadie',NULL,NULL,1),
	(33,'Cerulli.et','Cerulli Etiopici/Ethiopic',NULL,NULL,1),
	(34,'Cerulli.pers','Cerulli Persiani/Persian',NULL,NULL,1),
	(35,'Chig','Chigiani',NULL,NULL,1),
	(36,'Comb','Comboniani',NULL,NULL,1),
	(37,'De.Marinis','De Marinis',NULL,NULL,1),
	(38,'Ferr','Ferrajoli',NULL,NULL,1),
	(39,'Legat','Legature',NULL,NULL,1),
	(40,'Neofiti','Neofiti',NULL,NULL,1),
	(41,'Ott.gr','Ottoboniani Greci/Greek',NULL,NULL,1),
	(42,'Ott.lat','Ottoboniani Latini/Latin',NULL,NULL,1),
	(43,'P.I.O','Pontificio Istituto Orientale',NULL,NULL,1),
	(44,'Pagès','Pagès',NULL,NULL,1),
	(45,'Pal.gr','Palatini Greci/Greek',NULL,NULL,1),
	(46,'Pal.lat','Palatini Latini/Latin',NULL,NULL,1),
	(47,'Pap.Bodmer','Papiri Bodmer',NULL,NULL,1),
	(48,'Pap.Hanna','Papiri Hanna ',NULL,NULL,1),
	(49,'Pap.Vat.copt','Papiri Vaticani Copti/Coptic',NULL,NULL,1),
	(50,'Pap.Vat.gr','Papiri Vaticani Greci/Greek',NULL,NULL,1),
	(51,'Pap.Vat.lat','Papiri Vaticani Latini/Latin',NULL,NULL,1),
	(52,'Patetta','Patteta',NULL,NULL,1),
	(53,'Raineri','Raineri',NULL,NULL,1),
	(54,'Reg.gr','Reginensi Greci/Greek',NULL,NULL,1),
	(55,'Reg.gr.Pio.II','Reginensi Greci di Pio II/Greek',NULL,NULL,1),
	(56,'Reg.lat','Reginensi Latini/Latin',NULL,NULL,1),
	(57,'Ross','Rossiani',NULL,NULL,1),
	(58,'Ruoli','Ruoli',NULL,NULL,1),
	(59,'S.Maria.Magg','Santa Maria Maggiore',NULL,NULL,1),
	(60,'S.Maria.in.Via.Lata','Santa Maria in Via Lata',NULL,NULL,1),
	(61,'Sbath','Sbath',NULL,NULL,1),
	(62,'Sire','Sire',NULL,NULL,1),
	(63,'Urb.ebr','Urbinati Ebraici/Hebrew',NULL,NULL,1),
	(64,'Urb.gr','Urbinati Greci/Greek',NULL,NULL,1),
	(65,'Urb.lat','Urbinati Latini/Latin',NULL,NULL,1),
	(66,'Vat.ar','Vaticani Arabi/Arabic',NULL,NULL,1),
	(67,'Vat.arm','Vaticani Armeni/Armenian',NULL,NULL,1),
	(68,'Vat.copt','Vaticani Copti/Coptic',NULL,NULL,1),
	(69,'Vat.ebr','Vaticani Ebraici/Hebrew',NULL,NULL,1),
	(70,'Vat.estr.or','Vaticani Estremo-Orientali',NULL,NULL,1),
	(71,'Vat.et','Vaticani Etiopici',NULL,NULL,1),
	(72,'Vat.gr','Vaticani Greci/Greek',NULL,NULL,1),
	(73,'Vat.iber','Vaticani Iberici/Georgian',NULL,NULL,1),
	(74,'Vat.ind','Vaticani Indiani/Indian',NULL,NULL,1),
	(75,'Vat.indocin','Vaticani Indocinesi/Indochinese',NULL,NULL,1),
	(76,'Vat.lat','Vaticani Latini/Latin',NULL,NULL,1),
	(77,'Vat.mus','Vaticani Musicali',NULL,NULL,1),
	(78,'Vat.pers','Vaticani Persiani/Persian',NULL,NULL,1),
	(79,'Vat.sam','Vaticani Samaritani/Samaritan',NULL,NULL,1),
	(80,'Vat.sir','Vaticani Siriaci/Syriac',NULL,NULL,1),
	(81,'Vat.slav','Vaticani Slavi/Slavic',NULL,NULL,1),
	(82,'Vat.turc','Vaticani Turchi/Turkish',NULL,NULL,1),
	(83,'Borg.georg','Borgiana Georgiana/Georgian',NULL,NULL,1),
	(84,'Borg.irl','Borgiani Irlandesi/Irish',NULL,NULL,1),
	(85,'Pap.borg.dem','Papiri Borgiani Demotici',NULL,NULL,1),
	(86,'Pap.vat.dem','Papiri Vaticani Demotici',NULL,NULL,1),
	(88,'Vat.mand','Vaticani Mandei',NULL,NULL,1),
	(89,'Var.rum','Vaticani Rumeni/Romanian',NULL,NULL,1);

/*!40000 ALTER TABLE `fonds` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;


/* This data was taken from https://ptolemaeus.badw.de/start
the Ptolemaeus Arabus et Latinus project.  All links refer 
back to that site */

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
SET NAMES utf8mb4;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table ptolemy_sources
# ------------------------------------------------------------

DROP TABLE IF EXISTS `ptolemy_sources`;

CREATE TABLE `ptolemy_sources` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `shelfmark` varchar(32) DEFAULT NULL,
  `author` varchar(128) DEFAULT NULL,
  `title` varchar(256) DEFAULT NULL,
  `siglum` varchar(16) DEFAULT NULL,
  `url` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `ptolemy_sources` WRITE;
/*!40000 ALTER TABLE `ptolemy_sources` DISABLE KEYS */;

INSERT INTO `ptolemy_sources` (`id`, `shelfmark`, `author`, `title`, `siglum`, `url`)
VALUES
	(1,'Barb.lat.156','Regiomontanus','Epitome Almagesti','C.1.21','https://ptolemaeus.badw.de/ms/428#\r'),
	(2,'Barb.lat.172','Ptolemy','Quadripartitum (tr. Aegidius de Tebaldis)','A.2.5','https://ptolemaeus.badw.de/ms/448#\r'),
	(3,'Barb.lat.173','Ptolemy','Almagesti (tr. Gerard of Cremona)','A.1.2','https://ptolemaeus.badw.de/ms/156#\r'),
	(4,'Barb.lat.182','Ptolemy','Almagesti (tr. Gerard of Cremona)','A.1.2','https://ptolemaeus.badw.de/ms/157#\r'),
	(5,'Barb.lat.182','Thebit Bencora','De hiis que indigent expositione antequam legatur Almagesti','C.1.1','https://ptolemaeus.badw.de/ms/157#\r'),
	(6,'Barb.lat.304','Ptolemy','Liber de analemmate (tr. William of Moerbeke)','A.5.1','https://ptolemaeus.badw.de/ms/495#\r'),
	(7,'Barb.lat.328','Ptolemy','Quadripartitum (tr. Plato of Tivoli)','A.2.1','https://ptolemaeus.badw.de/ms/451#\r'),
	(8,'Barb.lat.328','Pseudo-Ptolemy','De iudiciis partium','B.6','https://ptolemaeus.badw.de/ms/451#\r'),
	(9,'Barb.lat.328','Pseudo-Ptolemy','Centiloquium (tr. Plato of Tivoli)','B.1.2','https://ptolemaeus.badw.de/ms/451#\r'),
	(10,'Barb.lat.328','Pseudo-Ptolemy','De cometis','B.4','https://ptolemaeus.badw.de/ms/451#\r'),
	(11,'Barb.lat.328','Pseudo-Ptolemy','Liber proiectionis radiorum stellarum','B.18','https://ptolemaeus.badw.de/ms/451#\r'),
	(12,'Barb.lat.336','Ptolemy','Almagesti (tr. Gerard of Cremona)','A.1.2','https://ptolemaeus.badw.de/ms/158#\r'),
	(13,'Borgh.312','Pseudo-Ptolemy','Centiloquium (tr. Plato of Tivoli)','B.1.2','https://ptolemaeus.badw.de/ms/551#\r'),
	(14,'Borgh.312','Pseudo-Ptolemy','De cometis','B.4','https://ptolemaeus.badw.de/ms/551#\r'),
	(15,'Cappon.255','Ptolemy','Quadripartitum (tr. Pancratius Florentinus)','A.2.13','https://ptolemaeus.badw.de/ms/432#\r'),
	(16,'Cappon.255','Pseudo-Ptolemy','Centiloquium (tr. Pancratius Florentinus)','B.1.10','https://ptolemaeus.badw.de/ms/432#\r'),
	(17,'Chigi.E.VI.202','Pseudo-Ptolemy','Iudicia','B.12','https://ptolemaeus.badw.de/ms/500#\r'),
	(18,'Chigi.F.IV.48','Ptolemy','Quadripartitum (tr. anonymous, before c. 1250)','A.2.4','https://ptolemaeus.badw.de/ms/437#\r'),
	(19,'Ott.lat.1552','Pseudo-Ptolemy','Liber proiectionis radiorum stellarum','B.18','https://ptolemaeus.badw.de/ms/481#\r'),
	(20,'Ott.lat.1552','Pseudo-Ptolemy','De iudiciis partium','B.6','https://ptolemaeus.badw.de/ms/481#\r'),
	(21,'Ott.lat.1826','Ptolemy','Almagesti (tr. anonymous in Sicily)','A.1.1','https://ptolemaeus.badw.de/ms/203#\r'),
	(22,'Ott.lat.1850','Ptolemy','Liber de analemmate (tr. William of Moerbeke)','A.5.1','https://ptolemaeus.badw.de/ms/228#\r'),
	(23,'Ott.lat.2234','Geber','Liber super Almagesti','C.1.2','https://ptolemaeus.badw.de/ms/463#\r'),
	(24,'Pal.lat.1116','Anonymous','Glosa super 60 propositionem Centilogii Ptholomei','C.3.10.1','https://ptolemaeus.badw.de/ms/372#\r'),
	(25,'Pal.lat.1122','Pseudo-Ptolemy','Centiloquium (version ÔMundanorumÕ)','B.1.4','https://ptolemaeus.badw.de/ms/576#\r'),
	(26,'Pal.lat.1188','Ptolemy','Quadripartitum (tr. Plato of Tivoli)','A.2.1','https://ptolemaeus.badw.de/ms/499#\r'),
	(27,'Pal.lat.1340','Pseudo-Ptolemy','Centiloquium (version ÔMundanorumÕ)','B.1.4','https://ptolemaeus.badw.de/ms/578#\r'),
	(28,'Pal.lat.1354','Pseudo-Ptolemy','De imaginibus super facies signorum','B.5','https://ptolemaeus.badw.de/ms/579#\r'),
	(29,'Pal.lat.1365','Ptolemy','Almagesti (tr. Gerard of Cremona)','A.1.2','https://ptolemaeus.badw.de/ms/162#\r'),
	(30,'Pal.lat.1366','Anonymous','Epitome of the Quadripartitum','C.2.22','https://ptolemaeus.badw.de/ms/347#\r'),
	(31,'Pal.lat.1368','Pseudo-Ptolemy','Centiloquium (version ÔMundanorumÕ)','B.1.4','https://ptolemaeus.badw.de/ms/582#\r'),
	(32,'Pal.lat.1369','Pseudo-Ptolemy','Centiloquium (tr. Plato of Tivoli)','B.1.2','https://ptolemaeus.badw.de/ms/587#\r'),
	(33,'Pal.lat.1371','Ptolemy','Almagesti (tr. anonymous in Sicily)','A.1.1','https://ptolemaeus.badw.de/ms/226#\r'),
	(34,'Pal.lat.1376','Johannes Andree Schindel','Tractatus de quantitate trium solidorum','C.1.15','https://ptolemaeus.badw.de/ms/719#\r'),
	(35,'Pal.lat.1376','Pseudo-Ptolemy','De cometis','B.4','https://ptolemaeus.badw.de/ms/719#\r'),
	(36,'Pal.lat.1380','Reimbotus de Castro','Commentary on the Centiloquium','C.3.2','https://ptolemaeus.badw.de/ms/588#\r'),
	(37,'Pal.lat.1380','Anonymous','Erfurt Commentary on the Almagest I','C.1.9','https://ptolemaeus.badw.de/ms/588#\r'),
	(38,'Pal.lat.1381','Pseudo-Ptolemy','Centiloquium (version ÔMundanorumÕ)','B.1.4','https://ptolemaeus.badw.de/ms/589#\r'),
	(39,'Pal.lat.1390','Pseudo-Ptolemy','Centiloquium (version ÔMundanorumÕ)','B.1.4','https://ptolemaeus.badw.de/ms/720#\r'),
	(40,'Pal.lat.1390','Ptolemy','Quadripartitum (tr. Aegidius de Tebaldis)','A.2.5','https://ptolemaeus.badw.de/ms/720#\r'),
	(41,'Pal.lat.1408','Pseudo-Ptolemy','Iudicia','B.12','https://ptolemaeus.badw.de/ms/545#\r'),
	(42,'Pal.lat.1408','Pseudo-Ptolemy','De temporum mutatione','B.9','https://ptolemaeus.badw.de/ms/545#\r'),
	(43,'Pal.lat.1408','Pseudo-Ptolemy','Centiloquium (tr. Plato of Tivoli)','B.1.2','https://ptolemaeus.badw.de/ms/545#\r'),
	(44,'Pal.lat.1414','Pseudo-Ptolemy','Liber figure','B.17','https://ptolemaeus.badw.de/ms/239#\r'),
	(45,'Pal.lat.1419','Ptolemy','Quadripartitum (tr. Aegidius de Tebaldis)','A.2.5','https://ptolemaeus.badw.de/ms/355#\r'),
	(46,'Pal.lat.1420','Ptolemy','Quadripartitum (tr. Plato of Tivoli)','A.2.1','https://ptolemaeus.badw.de/ms/363#\r'),
	(47,'Pal.lat.1420','Pseudo-Ptolemy','Liber proiectionis radiorum stellarum','B.18','https://ptolemaeus.badw.de/ms/363#\r'),
	(48,'Pal.lat.1445','Ptolemy','Quadripartitum (tr. Aegidius de Tebaldis)','A.2.5','https://ptolemaeus.badw.de/ms/452#\r'),
	(49,'Pal.lat.1446','Pseudo-Ptolemy','De occultis','B.8','https://ptolemaeus.badw.de/ms/723#\r'),
	(50,'Pal.lat.1811','Pseudo-Ptolemy','Centiloquium (tr. Plato of Tivoli)','B.1.2','https://ptolemaeus.badw.de/ms/721#\r'),
	(51,'Pal.lat.1892','Pseudo-Ptolemy','De iudiciis partium','B.6','https://ptolemaeus.badw.de/ms/722#\r'),
	(52,'Reg.lat.1012','Anonymous','Almagesti minor','C.1.3','https://ptolemaeus.badw.de/ms/159#\r'),
	(53,'Reg.lat.1241','Thebit Bencora','De hiis que indigent expositione antequam legatur Almagesti','C.1.1','https://ptolemaeus.badw.de/ms/464#\r'),
	(54,'Reg.lat.1261','Anonymous','Almagesti minor','C.1.3','https://ptolemaeus.badw.de/ms/160#\r'),
	(55,'Reg.lat.1285','Pseudo-Ptolemy','Centiloquium (tr. Plato of Tivoli)','B.1.2','https://ptolemaeus.badw.de/ms/195#\r'),
	(56,'Reg.lat.1285','Ptolemy','Quadripartitum (tr. Plato of Tivoli)','A.2.1','https://ptolemaeus.badw.de/ms/195#\r'),
	(57,'Reg.lat.1285','Pseudo-Ptolemy','Liber proiectionis radiorum stellarum','B.18','https://ptolemaeus.badw.de/ms/195#\r'),
	(58,'Reg.lat.1285','Ptolemy','Planispherium (tr. Hermann of Carinthia)','A.6.1','https://ptolemaeus.badw.de/ms/195#\r'),
	(59,'Reg.lat.1452','Pseudo-Ptolemy','Centiloquium (tr. Plato of Tivoli)','B.1.2','https://ptolemaeus.badw.de/ms/393#\r'),
	(60,'Reg.lat.1452','Pseudo-Ptolemy','De imaginibus super facies signorum','B.5','https://ptolemaeus.badw.de/ms/393#\r'),
	(61,'Reg.lat.1452','Anonymous','Glosa super 60 propositionem Centilogii Ptholomei','C.3.10.1','https://ptolemaeus.badw.de/ms/393#\r'),
	(62,'Reg.lat.1692','Pseudo-Ptolemy','Centiloquium (tr. Plato of Tivoli)','B.1.2','https://ptolemaeus.badw.de/ms/724#\r'),
	(63,'Reg.lat.1904','Giovanni Bianchini','Flores Almagesti','C.1.16','https://ptolemaeus.badw.de/ms/471#\r'),
	(64,'Reg.lat.1904','Thebit Bencora','De hiis que indigent expositione antequam legatur Almagesti','C.1.1','https://ptolemaeus.badw.de/ms/471#\r'),
	(65,'Urb.lat.267','Ptolemy','Quadripartitum (tr. Plato of Tivoli)','A.2.1','https://ptolemaeus.badw.de/ms/324#\r'),
	(66,'Urb.lat.1393','Pseudo-Ptolemy','Centiloquium (tr. Giovanni Pontano)','B.1.9','https://ptolemaeus.badw.de/ms/308#\r'),
	(67,'Vat.lat.971','Ptolemy','Almagesti (tr. George of Trebizond)','A.1.4','https://ptolemaeus.badw.de/ms/474#\r'),
	(68,'Vat.lat.1112','Pseudo-Ptolemy','Dixerunt Ptolemeus et Hermes quod locus Lune in hora...','B.10','https://ptolemaeus.badw.de/ms/472#\r'),
	(69,'Vat.lat.2054','Ptolemy','Almagesti (tr. George of Trebizond)','A.1.4','https://ptolemaeus.badw.de/ms/446#\r'),
	(70,'Vat.lat.2055','Ptolemy','Almagesti (tr. George of Trebizond)','A.1.4','https://ptolemaeus.badw.de/ms/447#\r'),
	(71,'Vat.lat.2056','Ptolemy','Almagesti (tr. anonymous in Sicily)','A.1.1','https://ptolemaeus.badw.de/ms/227#\r'),
	(72,'Vat.lat.2057','Ptolemy','Almagesti (tr. Gerard of Cremona)','A.1.2','https://ptolemaeus.badw.de/ms/163#\r'),
	(73,'Vat.lat.2058','George of Trebizond','Commentary on the Almagest','C.1.19','https://ptolemaeus.badw.de/ms/473#\r'),
	(74,'Vat.lat.2059','Geber','Liber super Almagesti','C.1.2','https://ptolemaeus.badw.de/ms/449#\r'),
	(75,'Vat.lat.2228','Giovanni Bianchini','Flores Almagesti','C.1.16','https://ptolemaeus.badw.de/ms/476#\r'),
	(76,'Vat.lat.3096','Ptolemy','Planispherium (tr. Hermann of Carinthia)','A.6.1','https://ptolemaeus.badw.de/ms/410#\r'),
	(77,'Vat.lat.3096','Geber','Liber super Almagesti','C.1.2','https://ptolemaeus.badw.de/ms/410#\r'),
	(78,'Vat.lat.3096','Pseudo-Ptolemy','Centiloquium (version ÔMundanorumÕ)','B.1.4','https://ptolemaeus.badw.de/ms/410#\r'),
	(79,'Vat.lat.3096','Pseudo-Ptolemy','De cometis','B.4','https://ptolemaeus.badw.de/ms/410#\r'),
	(80,'Vat.lat.3096','Pseudo-Ptolemy','Dixerunt Ptolemeus et Hermes quod locus Lune in hora...','B.10','https://ptolemaeus.badw.de/ms/410#\r'),
	(81,'Vat.lat.3100','Anonymous','Vatican Commentary on the Almagest','C.1.6','https://ptolemaeus.badw.de/ms/323#\r'),
	(82,'Vat.lat.3379','Laurentius Bonincontrius','Commentum super Centiloquio Ptholomei','C.3.4','https://ptolemaeus.badw.de/ms/374#\r'),
	(83,'Vat.lat.4075','Ptolemy','Quadripartitum (tr. anonymous, before c. 1250)','A.2.4','https://ptolemaeus.badw.de/ms/436#\r'),
	(84,'Vat.lat.4076','Pseudo-Ptolemy','Centiloquium (tr. George of Trebizond)','B.1.7','https://ptolemaeus.badw.de/ms/478#\r'),
	(85,'Vat.lat.4082','Andalo di Negro','De infusione spermatis','C.3.8.1','https://ptolemaeus.badw.de/ms/596#\r'),
	(86,'Vat.lat.4085','Andalo di Negro','De infusione spermatis','C.3.8.1','https://ptolemaeus.badw.de/ms/598#\r'),
	(87,'Vat.lat.4085','Pseudo-Ptolemy','De imaginibus super facies signorum','B.5','https://ptolemaeus.badw.de/ms/598#\r'),
	(88,'Vat.lat.4087','Pseudo-Ptolemy','Liber proiectionis radiorum stellarum','B.18','https://ptolemaeus.badw.de/ms/599#\r'),
	(89,'Vat.lat.5714','Pseudo-Ptolemy','Centiloquium (anonymous tr., 12th c.?)','B.1.6','https://ptolemaeus.badw.de/ms/294#\r'),
	(90,'Vat.lat.5984','Pseudo-Ptolemy','Centiloquium (tr. Giovanni Pontano)','B.1.9','https://ptolemaeus.badw.de/ms/309#\r'),
	(91,'Vat.lat.6766','Pseudo-Ptolemy','Iudicia','B.12','https://ptolemaeus.badw.de/ms/321#\r'),
	(92,'Vat.lat.6766','Pseudo-Ptolemy','Centiloquium (tr. Plato of Tivoli)','B.1.2','https://ptolemaeus.badw.de/ms/321#\r'),
	(93,'Vat.lat.6766','Ptolemy','Quadripartitum (tr. Plato of Tivoli)','A.2.1','https://ptolemaeus.badw.de/ms/321#\r'),
	(94,'Vat.lat.6766','Pseudo-Ptolemy','De temporum mutatione','B.9','https://ptolemaeus.badw.de/ms/321#\r'),
	(95,'Vat.lat.6788','Ptolemy','Almagesti (tr. Gerard of Cremona)','A.1.2','https://ptolemaeus.badw.de/ms/441#\r'),
	(96,'Vat.lat.6795','Anonymous','Vatican Commentary on the Almagest','C.1.6','https://ptolemaeus.badw.de/ms/322#\r'),
	(97,'Vat.lat.7616','Ptolemy','Quadripartitum (tr. Plato of Tivoli)','A.2.1','https://ptolemaeus.badw.de/ms/439#\r'),
	(98,'Vat.lat.7616','Pseudo-Ptolemy','Liber proiectionis radiorum stellarum','B.18','https://ptolemaeus.badw.de/ms/439#\r'),
	(99,'Vat.lat.7616','Pseudo-Ptolemy','Centiloquium (tr. Plato of Tivoli)','B.1.2','https://ptolemaeus.badw.de/ms/439#\r'),
	(100,'Vat.lat.11253','Pseudo-Ptolemy','Liber de nativitatibus hominum','B.16','https://ptolemaeus.badw.de/ms/479#\r'),
	(101,'Vat.lat.11573','Regiomontanus','Epitome Almagesti','C.1.21','https://ptolemaeus.badw.de/ms/429#\r'),
	(102,'Vat.lat.11817','Anonymous','Commentary on the Quadripartitum','C.2.25','https://ptolemaeus.badw.de/ms/552#');

/*!40000 ALTER TABLE `ptolemy_sources` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

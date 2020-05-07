
/* This data was taken from http://codpallat.uni-hd.de
the Virtual Palatine Library at the University of Heidelberg */

SET NAMES utf8mb4;

DROP TABLE IF EXISTS `pal_lat_gr_sources`;

CREATE TABLE `pal_lat_gr_sources` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `shelfmark` varchar(32) NOT NULL,
  `url` varchar(256) DEFAULT NULL,
  `description` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

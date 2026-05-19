# ************************************************************
# Sequel Ace SQL dump
# Version 20100
#
# https://sequel-ace.com/
# https://github.com/Sequel-Ace/Sequel-Ace
#
# Host: wiglaf-prod-baalstack-w00di8lza8gr-baaldbcluster02-3nnnocf1zfmr.cluster-cww5r8cocxqa.us-east-1.rds.amazonaws.com (MySQL 8.0.42)
# Database: vatican_mss
# Generation Time: 2026-05-06 20:11:31 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
SET NAMES utf8mb4;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE='NO_AUTO_VALUE_ON_ZERO', SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table adhoc_reports
# ------------------------------------------------------------

CREATE TABLE `adhoc_reports` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `query` text,
  `short_title` varchar(64) DEFAULT NULL,
  `header_text` text,
  `footer_text` text,
  `filename` varchar(64) DEFAULT NULL,
  `enabled` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;



# Dump of table fond_families
# ------------------------------------------------------------

CREATE TABLE `fond_families` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(64) DEFAULT NULL,
  `name` varchar(64) DEFAULT NULL,
  `header_text` text,
  `enabled` smallint NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



# Dump of table fonds
# ------------------------------------------------------------

CREATE TABLE `fonds` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(64) CHARACTER SET utf32 COLLATE utf32_general_ci DEFAULT NULL,
  `full_name` varchar(128) CHARACTER SET utf32 COLLATE utf32_general_ci DEFAULT NULL,
  `header_text` text CHARACTER SET utf32 COLLATE utf32_general_ci,
  `image_filename` varchar(128) CHARACTER SET utf32 COLLATE utf32_bin DEFAULT NULL,
  `volume_count` int DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_uniq` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=91 DEFAULT CHARSET=utf32;



# Dump of table linked_sources
# ------------------------------------------------------------

CREATE TABLE `linked_sources` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `raw_shelfmark` varchar(32) DEFAULT NULL,
  `shelfmark` varchar(32) DEFAULT NULL,
  `url` varchar(256) DEFAULT NULL,
  `link_name` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `shelfmark_idx` (`shelfmark`),
  KEY `link_name_idx` (`link_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf32;



# Dump of table manuscripts
# ------------------------------------------------------------

CREATE TABLE `manuscripts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `shelfmark` varchar(32) CHARACTER SET utf32 COLLATE utf32_bin DEFAULT NULL,
  `author` varchar(128) DEFAULT NULL,
  `title` varchar(256) DEFAULT NULL,
  `incipit` varchar(256) DEFAULT NULL,
  `date` varchar(32) DEFAULT NULL,
  `notes` text,
  `high_quality` int DEFAULT NULL,
  `details_page` tinyint(1) DEFAULT NULL,
  `details_count` int DEFAULT NULL,
  `bibliography_count` int DEFAULT NULL,
  `thumbnail_url` varchar(256) DEFAULT NULL,
  `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `date_added` timestamp NULL DEFAULT NULL,
  `sort_shelfmark` varchar(64) DEFAULT NULL,
  `fond_code` varchar(64) CHARACTER SET utf32 COLLATE utf32_general_ci DEFAULT NULL,
  `ignore` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `shelfmark_quality` (`shelfmark`,`high_quality`),
  KEY `fond_code_idx` (`fond_code`),
  CONSTRAINT `manuscripts_ibfk_1` FOREIGN KEY (`fond_code`) REFERENCES `fonds` (`code`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf32;



# Dump of table weekly_notes
# ------------------------------------------------------------

CREATE TABLE `weekly_notes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `year` int DEFAULT NULL,
  `week_number` int DEFAULT NULL,
  `header_text` text CHARACTER SET utf32 COLLATE utf32_general_ci NOT NULL,
  `image_filename` varchar(128) CHARACTER SET utf32 COLLATE utf32_general_ci DEFAULT NULL,
  `boundry_image_filename` varchar(128) CHARACTER SET utf32 COLLATE utf32_general_ci DEFAULT NULL,
  `previous_id` bigint unsigned DEFAULT NULL,
  `last_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `published` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `previous_id_idx` (`previous_id`),
  CONSTRAINT `previous_fkey` FOREIGN KEY (`previous_id`) REFERENCES `weekly_notes` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;



# Dump of table yearly_notes
# ------------------------------------------------------------

CREATE TABLE `yearly_notes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `year` int DEFAULT NULL,
  `header_text` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;




/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

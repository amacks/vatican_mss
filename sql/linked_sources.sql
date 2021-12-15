/* Build a generic table for linked sources, JONAS is the first example */

CREATE TABLE `linked_sources` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `raw_shelfmark` varchar(32) DEFAULT NULL,
  `shelfmark` varchar(32) DEFAULT NULL,
  `url` varchar(256) DEFAULT NULL,
  `link_name` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `shelfmark_idx` (`shelfmark`),
  KEY `link_name_idx` (`link_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf32;
CREATE TABLE `weekly_notes_previous` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `weekly_notes_id` bigint(20) unsigned NOT NULL,
  `previous_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `weekly_notes_id_idx` (`weekly_notes_id`),
  INDEX `previous_id_idx` (`previous_id`),
  CONSTRAINT `weekly_id_ibfk_1` FOREIGN KEY (`weekly_notes_id`) REFERENCES `weekly_notes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `previous_id_ibfk_1` FOREIGN KEY (`previous_id`) REFERENCES `weekly_notes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
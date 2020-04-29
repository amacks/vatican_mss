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

## View combining the weekly notes and the previous and next links
create or replace view `weekly_notes_linked` as (select 
weekly_notes.id as id,
weekly_notes.year as year,
weekly_notes.week_number as week_number,
weekly_notes.header_text as header_text,
weekly_notes.image_filename as image_filename,
weekly_notes.boundry_image_filename as boundry_image_filename,
previous.previous_id as previous_week_id,
next.weekly_notes_id as next_week_id
FROM weekly_notes left join weekly_notes_previous as previous on weekly_notes.id=previous.weekly_notes_id
left join weekly_notes_previous as next on weekly_notes.id=next.previous_id);

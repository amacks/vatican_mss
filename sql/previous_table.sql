## add a previous_id column
ALTER TABLE `weekly_notes` ADD `previous_id` bigint(20) unsigned DEFAULT NULL;

## setup a constraint on the previous_id column
ALTER TABLE `weekly_notes` 
	ADD CONSTRAINT `previous_fkey` FOREIGN KEY (`previous_id`) REFERENCES `weekly_notes` (`id`) 
	ON DELETE SET NULL ON UPDATE CASCADE;


## View combining the weekly notes and the previous and next links
create or replace view `weekly_notes_linked` as (select 
weekly_notes.id as id,
weekly_notes.year as year,
weekly_notes.week_number as week_number,
weekly_notes.header_text as header_text,
weekly_notes.image_filename as image_filename,
weekly_notes.boundry_image_filename as boundry_image_filename,
weekly_notes.previous_id as previous_week_id,
next.id as next_week_id,
next.year as next_week_year,
next.week_number as next_week_week_number
FROM weekly_notes as weekly_notes 
left outer join weekly_notes as next on weekly_notes.id=next.previous_id
left outer join weekly_notes as previous on weekly_notes.previous_id = previous.id);

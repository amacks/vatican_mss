/* Create a published column, defaults to false */
ALTER TABLE `weekly_notes` ADD `published` BOOL  NOT NULL 
	DEFAULT '0' AFTER `last_updated`;
/* now set everything to true for the moment */
update weekly_notes set published=true;
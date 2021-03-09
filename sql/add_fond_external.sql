/* These SQL statements will add a fond_code column to the manuscripts table and set the 
fonds.code column as an external constraint.  They must be run after the fonds table has been created */

ALTER TABLE `manuscripts` ADD `fond_code` VARCHAR(64)  
	CHARACTER SET utf8mb4  COLLATE utf8mb4_general_ci NULL  DEFAULT NULL  AFTER `sort_shelfmark`;

ALTER TABLE `manuscripts` ADD INDEX `fond_code_idx` (`fond_code`);

ALTER TABLE `manuscripts` 
	ADD CONSTRAINT `fond_code_ext` FOREIGN KEY (`fond_code`) 
	REFERENCES `vatican_mss`.`fonds` (`code`) 
	ON DELETE SET NULL ON UPDATE CASCADE;

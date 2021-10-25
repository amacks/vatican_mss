/* Add a column */
ALTER TABLE `weekly_notes` CHANGE `last_modified` `last_updated` 
	TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

/* set initial values */
update weekly_notes set last_updated= STR_TO_DATE(concat(year, " ", week_number, " Friday"), '%X %V %W');
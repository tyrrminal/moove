-- Revert moove:add_event_group_parent_flag from mysql

BEGIN;

ALTER TABLE `EventGroup` ADD COLUMN `year` SMALLINT NULL;

UPDATE `EventGroup` SET 
	`year` = CAST(REGEXP_REPLACE(`name`,'^([0-9]{4}).*', '\\1') AS INTEGER),
	`name` = REGEXP_REPLACE(`name`,'^[0-9]{4} (.*)$','\\1')
WHERE `is_parent`='N' 
AND `name` REGEXP '^([0-9]{4})';

ALTER TABLE `EventGroup` DROP COLUMN `is_parent`;


COMMIT;

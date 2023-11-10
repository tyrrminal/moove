-- Deploy moove:add_event_group_parent_flag to mysql

BEGIN;

ALTER TABLE `EventGroup` ADD COLUMN `is_parent` ENUM('Y','N') DEFAULT 'Y';

UPDATE `EventGroup` SET `name`=CONCAT(`year`,' ', `name`),`is_parent`='N' WHERE `year` IS NOT NULL;

ALTER TABLE `EventGroup` DROP COLUMN `year`;

COMMIT;

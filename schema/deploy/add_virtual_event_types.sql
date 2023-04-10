-- Deploy moove:add_virtual_event_types to mysql

BEGIN;

ALTER TABLE `EventType` ADD COLUMN `is_virtual` ENUM('Y','N') DEFAULT 'N';
UPDATE `EventType` SET `is_virtual`='Y' WHERE `description` LIKE 'Virtual%';

COMMIT;

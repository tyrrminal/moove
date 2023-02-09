-- Deploy moove:add_bodyweight_context to mysql

BEGIN;

INSERT INTO `ActivityContext` (`description`, `has_map`) VALUES
('Bodyweight', 'N');

UPDATE `ActivityType` 
SET `activity_context_id` = (SELECT `id` FROM `ActivityContext` WHERE `description` = 'Bodyweight') 
WHERE `activity_context_id` IS NULL;

ALTER TABLE `ActivityType` MODIFY COLUMN `activity_context_id` INT UNSIGNED NOT NULL;

COMMIT;

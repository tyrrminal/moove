-- Revert moove:add_bodyweight_context from mysql

BEGIN;

ALTER TABLE `ActivityType` MODIFY COLUMN `activity_context_id` INT UNSIGNED NULL;

UPDATE `ActivityType` 
SET `activity_context_id` = NULL
WHERE `activity_context_id` = (SELECT `id` FROM `ActivityContext` WHERE `description` = 'Bodyweight') ;

DELETE FROM `ActivityContext` WHERE `description` = 'Bodyweight';

COMMIT;

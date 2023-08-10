-- Revert moove:add_missing_activity_types from mysql

BEGIN;

DELETE t 
FROM `ActivityType` t
WHERE t.`id` IN (14,15,16)
AND NOT EXISTS (SELECT * FROM `Activity` a WHERE a.`activity_type_id` = t.`id`)
AND NOT EXISTS (SELECT * FROM `EventType` e WHERE e.`activity_type_id` = t.`id`)
AND NOT EXISTS (SELECT * FROM `UserNominalActivity` una WHERE una.`activity_type_id` = t.`id`);

COMMIT;

-- Revert moove:support_arbitrary_fields_for_event_import from mysql

BEGIN;

ALTER TABLE `EventActivity` ADD COLUMN `external_identifier` VARCHAR(45) NULL;
ALTER TABLE `Event`         ADD COLUMN `external_identifier` VARCHAR(45) NULL;

UPDATE `EventActivity` SET `external_identifier` = JSON_VALUE(`import_parameters`, '$.race_id');
UPDATE `Event` e JOIN `EventActivity` ea ON e.`id` = ea.`event_id` SET e.`external_identifier` = JSON_VALUE(ea.`import_parameters`, '$.event_id'); 

ALTER TABLE `EventActivity` DROP COLUMN `import_parameters`;

COMMIT;

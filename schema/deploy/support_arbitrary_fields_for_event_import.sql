-- Deploy moove:support_arbitrary_fields_for_event_import to mysql

BEGIN;

ALTER TABLE `EventActivity` ADD COLUMN `import_parameters` JSON NULL;

UPDATE `EventActivity` ea JOIN `Event` e ON ea.`event_id`=e.`id` SET `import_parameters` = JSON_OBJECT("event_id",e.`external_identifier`,"race_id", ea.`external_identifier`) WHERE e.`external_identifier` IS NOT NULL AND ea.`external_identifier` IS NOT NULL;
UPDATE `EventActivity` ea JOIN `Event` e ON ea.`event_id`=e.`id` SET `import_parameters` = JSON_OBJECT("event_id",e.`external_identifier`) WHERE e.`external_identifier` IS NOT NULL AND ea.`external_identifier` IS NULL;

ALTER TABLE `Event` DROP COLUMN `external_identifier`;
ALTER TABLE `EventActivity` DROP COLUMN `external_identifier`;

COMMIT;

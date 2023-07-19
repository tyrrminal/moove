-- Deploy moove:support_arbitrary_fields_for_event_import to mysql

BEGIN;

ALTER TABLE `Event`         ADD COLUMN `import_parameters` JSON NULL;
ALTER TABLE `EventActivity` ADD COLUMN `import_parameters` JSON NULL;

UPDATE `Event`         SET `import_parameters` = JSON_OBJECT("event_id", `external_identifier`) WHERE `external_identifier` IS NOT NULL;
UPDATE `EventActivity` SET `import_parameters` = JSON_OBJECT("race_id",  `external_identifier`) WHERE `external_identifier` IS NOT NULL;

ALTER TABLE `Event`         DROP COLUMN `external_identifier`;
ALTER TABLE `EventActivity` DROP COLUMN `external_identifier`;

COMMIT;

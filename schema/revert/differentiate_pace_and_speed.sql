-- Revert moove:differentiate_pace_and_speed from mysql

BEGIN;

ALTER TABLE `BaseActivityType` DROP COLUMN `has_speed`;
ALTER TABLE `BaseActivityType` DROP COLUMN `has_pace`;

ALTER TABLE `UnitOfMeasure` DROP COLUMN `inverted`;

DELETE FROM `UnitOfMeasure` WHERE `id`=6;

COMMIT;

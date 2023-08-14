-- Revert moove:use_calculated_pace_speed_cols from mysql

BEGIN;

UPDATE `ActivityResult` SET `pace`  = `speed_to_pace` WHERE `pace`  IS NULL AND `speed` IS NOT NULL;
UPDATE `ActivityResult` SET `speed` = `pace_to_speed` WHERE `speed` IS NULL AND `pace`  IS NOT NULL;

ALTER TABLE `ActivityResult` DROP COLUMN `pace_to_speed`;
ALTER TABLE `ActivityResult` DROP COLUMN `speed_to_pace`;

COMMIT;

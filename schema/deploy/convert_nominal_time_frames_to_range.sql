-- Deploy moove:convert_nominal_time_frames_to_range to mysql

BEGIN;

ALTER TABLE `UserNominalActivity` ADD COLUMN `start_date` DATE NOT NULL AFTER `activity_type_id`;
ALTER TABLE `UserNominalActivity` ADD COLUMN `end_date` DATE NULL AFTER `start_date`;

UPDATE `UserNominalActivity` una
LEFT JOIN `UserNominalActivityRange` unar
  ON una.`id` = unar.`user_nominal_activity_id`
SET 
  una.`start_date` = IFNULL(range_start,   CONCAT(year,'-01-01')),
  una.`end_date`   = IF(ISNULL(range_end), CONCAT(year,'-12-31'), DATE_SUB(range_end, INTERVAL 1 DAY));

ALTER TABLE `UserNominalActivity` DROP COLUMN `year`;

DROP TABLE IF EXISTS `UserNominalActivityRange`;

COMMIT;

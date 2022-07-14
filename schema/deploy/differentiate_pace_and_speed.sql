-- Deploy moove:differentiate_pace_and_speed to mysql

BEGIN;

ALTER TABLE `BaseActivityType` ADD COLUMN `has_pace` ENUM('Y','N') NOT NULL DEFAULT 'N';
ALTER TABLE `BaseActivityType` ADD COLUMN `has_speed` ENUM('Y','N') NOT NULL DEFAULT 'N';

UPDATE `BaseActivityType` SET `has_pace`='Y' WHERE id IN (1,5);
UPDATE `BaseActivityType` SET `has_speed`='Y' WHERE id IN (2,3,4);

ALTER TABLE `UnitOfMeasure` ADD COLUMN `inverted` ENUM('Y','N') NOT NULL DEFAULT 'N' AFTER `normalization_factor`;

INSERT INTO `UnitOfMeasure` (`id`,`name`,`abbreviation`,`normalization_factor`,`inverted`,`normal_unit_id`) VALUES
(6, 'minutes per mile', "/mi", 60, 'Y', 3);

COMMIT;

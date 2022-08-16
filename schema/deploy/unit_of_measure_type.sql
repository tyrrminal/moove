-- Deploy moove:unit_of_measure_type to mysql

BEGIN;

CREATE TABLE IF NOT EXISTS `UnitOfMeasureType` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `unit_of_measure_type_description_uniq` (`description` ASC)
);

INSERT INTO `UnitOfMeasureType` (`id`,`description`) VALUES
(1,'Distance'),
(2,'Rate');

ALTER TABLE `UnitOfMeasure` ADD COLUMN `unit_of_measure_type_id` INT UNSIGNED;

UPDATE `UnitOfMeasure` SET `unit_of_measure_type_id` = 1;
UPDATE `UnitOfMeasure` SET `unit_of_measure_type_id` = 2 WHERE `id` = 3 OR `normal_unit_id` = 3;

ALTER TABLE `UnitOfMeasure` ADD INDEX `fk_unit_of_measure_unit_of_measure_type1_idx` (`unit_of_measure_type_id`);
ALTER TABLE `UnitOfMeasure` ADD CONSTRAINT `fk_unit_of_measure_unit_of_measure_type1` FOREIGN KEY (`unit_of_measure_type_id`) REFERENCES `UnitOfMeasureType` (`id`);

COMMIT;

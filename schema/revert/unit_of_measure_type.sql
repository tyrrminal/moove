-- Revert moove:unit_of_measure_type from mysql

BEGIN;

ALTER TABLE `UnitOfMeasure` DROP CONSTRAINT `fk_unit_of_measure_unit_of_measure_type1`;
ALTER TABLE `UnitOfMeasure` DROP INDEX `fk_unit_of_measure_unit_of_measure_type1_idx`;
ALTER TABLE `UnitOfMeasure` DROP COLUMN `unit_of_measure_type_id`;

DROP TABLE IF EXISTS `UnitOfMeasureType`;

COMMIT;

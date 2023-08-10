-- Revert moove:convert_nominal_time_frames_to_range from mysql

BEGIN;

CREATE TABLE IF NOT EXISTS `UserNominalActivityRange` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`user_nominal_activity_id` INT UNSIGNED NOT NULL,
	`range_start` DATE NOT NULL,
	`range_end` DATE NOT NULL,
	PRIMARY KEY (`id`),
	INDEX `fk_UserNominalActivityRange_UserNominalActivity1_idx` (`user_nominal_activity_id` ASC),
	CONSTRAINT `fk_UserNominalActivityRange_UserNominalActivity1`
		FOREIGN KEY (`user_nominal_activity_id`)
		REFERENCES `UserNominalActivity` (`id`)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
) ENGINE = InnoDB;

ALTER TABLE `UserNominalActivity` ADD COLUMN `year` INT UNSIGNED NOT NULL AFTER `activity_type_id`;
UPDATE `UserNominalActivity` SET `year` = YEAR(`start_date`);

INSERT INTO `UserNominalActivityRange` (`user_nominal_activity_id`,`range_start`,`range_end`)
SELECT una.`id`, una.`start_date`, DATE_ADD(una.`end_date`, INTERVAL 1 DAY)
FROM `UserNominalActivity` una
WHERE YEAR(una.`start_date`)=YEAR(una.`end_date`)
AND (
	(MONTH(una.`start_date`) <>  1 OR DAY(una.`start_date`) <>  1) OR
	(MONTH(una.`end_date`)   <> 12 OR DAY(una.`end_date`)   <> 31)
);

ALTER TABLE `UserNominalActivity` DROP COLUMN `end_date`;
ALTER TABLE `UserNominalActivity` DROP COLUMN `start_date`;

COMMIT;

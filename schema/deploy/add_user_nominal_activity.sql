-- Deploy moove:add_user_nominal_activity to mysql

BEGIN;

CREATE TABLE IF NOT EXISTS `UserNominalActivity` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`user_id` INT UNSIGNED NOT NULL,
	`activity_type_id` INT UNSIGNED NOT NULL,
	`year` INT UNSIGNED NOT NULL,
	`value` JSON NOT NULL,
	PRIMARY KEY (`id`),
	INDEX `fk_UserNominalActivity_User1_idx` (`user_id` ASC),
	INDEX `fk_UserNominalActivity_ActivityType1_idx` (`activity_type_id` ASC),
  	CONSTRAINT `fk_UserNominalActivity_User1`
	    FOREIGN KEY (`user_id`)
	    REFERENCES `User` (`id`)
	    ON DELETE NO ACTION
	    ON UPDATE NO ACTION,
  	CONSTRAINT `fk_UserNominalActivity_ActivityType1`
	    FOREIGN KEY (`activity_type_id`)
	    REFERENCES `ActivityType` (`id`)
	    ON DELETE NO ACTION
	    ON UPDATE NO ACTION
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `UserNominalActivityRange` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`user_nominal_activity_id` INT UNSIGNED NOT NULL,
	`rangeStart` DATE NOT NULL,
	`rangeEnd` DATE NOT NULL,
	PRIMARY KEY (`id`),
	INDEX `fk_UserNominalActivityRange_UserNominalActivity1_idx` (`user_nominal_activity_id` ASC),
	CONSTRAINT `fk_UserNominalActivityRange_UserNominalActivity1`
		FOREIGN KEY (`user_nominal_activity_id`)
		REFERENCES `UserNominalActivity` (`id`)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
) ENGINE = InnoDB;

COMMIT;

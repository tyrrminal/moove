-- Deploy moove:add_friendships to mysql

BEGIN;

CREATE TABLE IF NOT EXISTS `Friendship` (
  `initiator_id` INT UNSIGNED NOT NULL,
  `receiver_id` INT UNSIGNED NOT NULL,
  `initiated_at` DATETIME NOT NULL,
  PRIMARY KEY (`initiator_id`,`receiver_id`),
  INDEX `fk_Friendship_User1_idx` (`initiator_id`),
  CONSTRAINT `fk_Friendship_User1`
    FOREIGN KEY (`initiator_id`)
    REFERENCES `User` (`id`)
    ON UPDATE NO ACTION
    ON DELETE NO ACTION,
  INDEX `fk_Friendship_User2_idx` (`receiver_id`),
  CONSTRAINT `fk_Friendship_User2`
    FOREIGN KEY (`receiver_id`)
    REFERENCES `User` (`id`)
    ON UPDATE NO ACTION
    ON DELETE NO ACTION)
ENGINE = InnoDB;

COMMIT;

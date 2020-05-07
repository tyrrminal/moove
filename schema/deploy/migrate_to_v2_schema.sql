-- Deploy moove:migrate_to_v2_schema to mysql

BEGIN;

-- -----------------------------------------------------
-- Disable Constraints
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO';

-- -----------------------------------------------------
-- DROP all FKs to avoid naming conflicts
-- -----------------------------------------------------
ALTER TABLE `activity` DROP FOREIGN KEY `fk_activity_activity1`;
ALTER TABLE `activity` DROP FOREIGN KEY `fk_activity_activity_type1`;
ALTER TABLE `activity` DROP FOREIGN KEY `fk_activity_distance1`;
ALTER TABLE `activity` DROP FOREIGN KEY `fk_activity_event1`;
ALTER TABLE `activity` DROP FOREIGN KEY `fk_activity_result1`;
ALTER TABLE `activity` DROP FOREIGN KEY `fk_activity_user1`;
ALTER TABLE `activity_point` DROP FOREIGN KEY `fk_activity_location_activity1`;
ALTER TABLE `activity_point` DROP FOREIGN KEY `fk_activity_location_location1`;
ALTER TABLE `activity_reference` DROP FOREIGN KEY `fk_activity_reference_activity_id`;
ALTER TABLE `distance` DROP FOREIGN KEY `fk_distance_unit_of_measure1`;
ALTER TABLE `donation` DROP FOREIGN KEY `fk_donation_person1`;
ALTER TABLE `donation` DROP FOREIGN KEY `fk_donation_event_registration1`;
ALTER TABLE `donation` DROP FOREIGN KEY `fk_donation_location1`;
ALTER TABLE `event` DROP FOREIGN KEY `fk_event_distance1`;
ALTER TABLE `event` DROP FOREIGN KEY `fk_event_event_group1`;
ALTER TABLE `event` DROP FOREIGN KEY `fk_event_event_type1`;
ALTER TABLE `event_group` DROP FOREIGN KEY `fk_event_group_address1`;
ALTER TABLE `event_group` DROP FOREIGN KEY `fk_event_group_event_sequence1`;
ALTER TABLE `event_group_series` DROP FOREIGN KEY `fk_event_series1`;
ALTER TABLE `event_group_series` DROP FOREIGN KEY `fk_event_group1`;
ALTER TABLE `event_reference` DROP FOREIGN KEY `fk_event_reference_event1`;
ALTER TABLE `event_reference` DROP FOREIGN KEY `fk_event_reference_event_reference_type1`;
ALTER TABLE `event_registration` DROP FOREIGN KEY `fk_user_has_event_event1`;
ALTER TABLE `event_registration` DROP FOREIGN KEY `fk_user_has_event_user`;
ALTER TABLE `event_result` DROP FOREIGN KEY `fk_event_result_event_result_group1`;
ALTER TABLE `event_result` DROP FOREIGN KEY `fk_event_result_result1`;
ALTER TABLE `event_result_group` DROP FOREIGN KEY `fk_event_result_group_division1`;
ALTER TABLE `event_result_group` DROP FOREIGN KEY `fk_event_result_group_event1`;
ALTER TABLE `event_result_group` DROP FOREIGN KEY `fk_event_result_group_gender1`;
ALTER TABLE `event_type` DROP FOREIGN KEY `fk_event_type_activity_type1`;
ALTER TABLE `goal` DROP FOREIGN KEY `fk_goal_goal_comparator1`;
ALTER TABLE `goal` DROP FOREIGN KEY `fk_goal_goal_span1`;
ALTER TABLE `goal` DROP FOREIGN KEY `fk_goal_activity_type`;
ALTER TABLE `goal` DROP FOREIGN KEY `fk_goal_dimension1`;
ALTER TABLE `goal` DROP FOREIGN KEY `fk_goal_distance1`;
ALTER TABLE `goal` DROP FOREIGN KEY `fk_goal_distance2`;
ALTER TABLE `goal` DROP FOREIGN KEY `fk_goal_distance3`;
ALTER TABLE `participant` DROP FOREIGN KEY `fk_participant_division1`;
ALTER TABLE `participant` DROP FOREIGN KEY `fk_participant_gender1`;
ALTER TABLE `participant` DROP FOREIGN KEY `fk_participant_location1`;
ALTER TABLE `participant` DROP FOREIGN KEY `fk_participant_person1`;
ALTER TABLE `participant` DROP FOREIGN KEY `fk_participant_result1`;
ALTER TABLE `unit_of_measure` DROP FOREIGN KEY `fk_uom_dimension1`;
ALTER TABLE `user` DROP FOREIGN KEY `fk_user_location1`;
ALTER TABLE `user` DROP FOREIGN KEY `fk_user_person1`;
ALTER TABLE `user_goal` DROP FOREIGN KEY `fk_user_goal_goal1`;
ALTER TABLE `user_goal` DROP FOREIGN KEY `fk_user_goal_user1`;
ALTER TABLE `user_goal_fulfillment` DROP FOREIGN KEY `fk_user_goal_fulfillment_user_goal1`;
ALTER TABLE `user_goal_fulfillment_activity` DROP FOREIGN KEY `fk_user_goal_fulfillment_has_activity_activity1`;
ALTER TABLE `user_goal_fulfillment_activity` DROP FOREIGN KEY `fk_user_goal_fulfillment_has_activity_user_goal_fulfillment1`;

-- -----------------------------------------------------
-- Rename existing tables
-- -----------------------------------------------------
RENAME TABLE `activity` TO `mig_activity`;
RENAME TABLE `activity_point` TO `mig_activity_point`;
RENAME TABLE `activity_reference` TO `mig_activity_reference`;
RENAME TABLE `activity_type` TO `mig_activity_type`;
RENAME TABLE `address` TO `mig_address`;
RENAME TABLE `dimension` TO `mig_dimension`;
RENAME TABLE `distance` TO `mig_distance`;
RENAME TABLE `division` TO `mig_division`;
RENAME TABLE `donation` TO `mig_donation`;
RENAME TABLE `event` TO `mig_event`;
RENAME TABLE `event_group` TO `mig_event_group`;
RENAME TABLE `event_group_series` TO `mig_event_group_series`;
RENAME TABLE `event_reference` TO `mig_event_reference`;
RENAME TABLE `event_reference_type` TO `mig_event_reference_type`;
RENAME TABLE `event_registration` TO `mig_event_registration`;
RENAME TABLE `event_result` TO `mig_event_result`;
RENAME TABLE `event_result_group` TO `mig_event_result_group`;
RENAME TABLE `event_sequence` TO `mig_event_sequence`;
RENAME TABLE `event_series` TO `mig_event_series`;
RENAME TABLE `event_type` TO `mig_event_type`;
RENAME TABLE `gender` TO `mig_gender`;
RENAME TABLE `goal` TO `mig_goal`;
RENAME TABLE `goal_comparator` TO `mig_goal_comparator`;
RENAME TABLE `goal_span` TO `mig_goal_span`;
RENAME TABLE `location` TO `mig_location`;
RENAME TABLE `participant` TO `mig_participant`;
RENAME TABLE `person` TO `mig_person`;
RENAME TABLE `result` TO `mig_result`;
RENAME TABLE `unit_of_measure` TO `mig_unit_of_measure`;
RENAME TABLE `user` TO `mig_user`;
RENAME TABLE `user_goal` TO `mig_user_goal`;
RENAME TABLE `user_goal_fulfillment` TO `mig_user_goal_fulfillment`;
RENAME TABLE `user_goal_fulfillment_activity` TO `mig_user_goal_fulfillment_activity`;

-- -----------------------------------------------------
-- Table `Person`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Person` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `firstname` VARCHAR(45) NOT NULL,
  `lastname` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `User`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `User` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(45) NOT NULL,
  `person_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `username_UNIQUE` (`username` ASC),
  INDEX `fk_User_Person_idx` (`person_id` ASC),
  CONSTRAINT `fk_User_Person`
    FOREIGN KEY (`person_id`)
    REFERENCES `Person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Gender`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Gender` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(10) NOT NULL,
  `abbreviation` VARCHAR(2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC),
  UNIQUE INDEX `abbreviation_UNIQUE` (`abbreviation` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Division`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Division` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `UnitOfMeasure`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `UnitOfMeasure` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `abbreviation` VARCHAR(10) NOT NULL,
  `normalization_factor` DECIMAL(20,10) UNSIGNED NOT NULL,
  `normal_unit_id` INT UNSIGNED NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC),
  UNIQUE INDEX `abbreviation_UNIQUE` (`abbreviation` ASC),
  INDEX `fk_UnitOfMeasure_UnitOfMeasure1_idx` (`normal_unit_id` ASC),
  CONSTRAINT `fk_UnitOfMeasure_UnitOfMeasure1`
    FOREIGN KEY (`normal_unit_id`)
    REFERENCES `UnitOfMeasure` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Distance`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Distance` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `value` DECIMAL(7,3) NOT NULL,
  `unit_of_measure_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Distance_UnitOfMeasure1_idx` (`unit_of_measure_id` ASC),
  CONSTRAINT `fk_Distance_UnitOfMeasure1`
    FOREIGN KEY (`unit_of_measure_id`)
    REFERENCES `UnitOfMeasure` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Address` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `street1` VARCHAR(45) NULL,
  `street2` VARCHAR(45) NULL,
  `city` VARCHAR(45) NULL,
  `state` VARCHAR(45) NULL,
  `zip` VARCHAR(10) NULL,
  `country` VARCHAR(45) NULL,
  `phone` VARCHAR(45) NULL,
  `email` VARCHAR(200) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Location`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Location` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `latitude` DECIMAL(9,6) NOT NULL,
  `longitude` DECIMAL(9,6) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Workout`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Workout` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `date` DATE NOT NULL,
  `name` VARCHAR(75) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Workout_User1_idx` (`user_id` ASC),
  CONSTRAINT `fk_Workout_User1`
    FOREIGN KEY (`user_id`)
    REFERENCES `User` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ActivityType`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ActivityType` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(45) NOT NULL,
  `is_cardio` ENUM('Y', 'N') NOT NULL DEFAULT 'N',
  `is_lift` ENUM('Y', 'N') NOT NULL DEFAULT 'N',
  `is_hold` ENUM('Y', 'N') NOT NULL DEFAULT 'N',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `description_UNIQUE` (`description` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ExternalDataSource`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ExternalDataSource` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `import_class` VARCHAR(200) NOT NULL,
  `base_url` VARCHAR(1024) NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `class_name_UNIQUE` (`name` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Activity`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Activity` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `workout_id` INT UNSIGNED NOT NULL,
  `start_time` DATETIME NULL,
  `note` TEXT NOT NULL DEFAULT '',
  `whole_activity_id` INT UNSIGNED NULL,
  `external_data_source_id` INT UNSIGNED NULL,
  `external_identifier` VARCHAR(100) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Activity_Activity1_idx` (`whole_activity_id` ASC),
  INDEX `fk_Activity_Workout1_idx` (`workout_id` ASC),
  INDEX `fk_Activity_ExternalDataSource1_idx` (`external_data_source_id` ASC),
  CONSTRAINT `fk_Activity_Activity1`
    FOREIGN KEY (`whole_activity_id`)
    REFERENCES `Activity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Activity_Workout1`
    FOREIGN KEY (`workout_id`)
    REFERENCES `Workout` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Activity_ExternalDataSource1`
    FOREIGN KEY (`external_data_source_id`)
    REFERENCES `ExternalDataSource` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ActivitySet`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ActivitySet` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `num` TINYINT UNSIGNED NOT NULL,
  `activity_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_ActivitySet_Activity1_idx` (`activity_id` ASC),
  CONSTRAINT `fk_ActivitySet_Activity1`
    FOREIGN KEY (`activity_id`)
    REFERENCES `Activity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `CardioActivityResult`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CardioActivityResult` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `gross_time` TIME NULL,
  `net_time` TIME NOT NULL,
  `pace` TIME NULL,
  `speed` DECIMAL(7,3) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `CardioActivitySet`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CardioActivitySet` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `activity_set_id` INT UNSIGNED NOT NULL,
  `distance_id` INT UNSIGNED NOT NULL,
  `heart_rate` SMALLINT UNSIGNED NULL,
  `weight` DECIMAL(6,2) NOT NULL DEFAULT 0,
  `cardio_activity_result_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_CardioActivity_Distance1_idx` (`distance_id` ASC),
  INDEX `fk_CardioActivity_CardioActivityResult1_idx` (`cardio_activity_result_id` ASC),
  INDEX `fk_CardioActivity_ActivitySet1_idx` (`activity_set_id` ASC),
  CONSTRAINT `fk_CardioActivity_Distance1`
    FOREIGN KEY (`distance_id`)
    REFERENCES `Distance` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_CardioActivity_CardioActivityResult1`
    FOREIGN KEY (`cardio_activity_result_id`)
    REFERENCES `CardioActivityResult` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_CardioActivity_ActivitySet1`
    FOREIGN KEY (`activity_set_id`)
    REFERENCES `ActivitySet` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `LiftActivitySet`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `LiftActivitySet` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `activity_set_id` INT UNSIGNED NOT NULL,
  `weight` DECIMAL(6,2) NOT NULL,
  `reps` SMALLINT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_LiftActivity_ActivitySet1_idx` (`activity_set_id` ASC),
  CONSTRAINT `fk_LiftActivity_ActivitySet1`
    FOREIGN KEY (`activity_set_id`)
    REFERENCES `ActivitySet` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `HoldActivitySet`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `HoldActivitySet` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `activity_set_id` INT UNSIGNED NOT NULL,
  `weight` DECIMAL(6,2) NOT NULL DEFAULT 0,
  `duration` TIME NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_HoldActivity_ActivitySet1_idx` (`activity_set_id` ASC),
  CONSTRAINT `fk_HoldActivity_ActivitySet1`
    FOREIGN KEY (`activity_set_id`)
    REFERENCES `ActivitySet` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `OutdoorActivitySet`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `OutdoorActivitySet` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `activity_set_id` INT UNSIGNED NOT NULL,
  `temperature` DECIMAL(4,1) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_OutdoorActivity_ActivitySet1_idx` (`activity_set_id` ASC),
  CONSTRAINT `fk_OutdoorActivity_ActivitySet1`
    FOREIGN KEY (`activity_set_id`)
    REFERENCES `ActivitySet` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ActivityPoint`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ActivityPoint` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `outdoor_activity_id` INT UNSIGNED NOT NULL,
  `timestamp` DATETIME NOT NULL,
  `location_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_ActivityPoint_OutdoorActivity1_idx` (`outdoor_activity_id` ASC),
  INDEX `fk_ActivityPoint_Location1_idx` (`location_id` ASC),
  CONSTRAINT `fk_ActivityPoint_OutdoorActivity1`
    FOREIGN KEY (`outdoor_activity_id`)
    REFERENCES `OutdoorActivitySet` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ActivityPoint_Location1`
    FOREIGN KEY (`location_id`)
    REFERENCES `Location` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `EventGroup`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EventGroup` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `url` TEXT NULL,
  `name` VARCHAR(45) NULL,
  `year` SMALLINT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Event`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Event` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `year` SMALLINT NOT NULL,
  `url` TEXT NULL,
  `address_id` INT UNSIGNED NOT NULL,
  `event_sequence_id` INT UNSIGNED NULL,
  `external_data_source_id` INT UNSIGNED NULL,
  `external_identifier` VARCHAR(45) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Event_Address1_idx` (`address_id` ASC),
  INDEX `fk_Event_EventGroup1_idx` (`event_sequence_id` ASC),
  INDEX `fk_Event_ExternalDataSource1_idx` (`external_data_source_id` ASC),
  CONSTRAINT `fk_Event_Address1`
    FOREIGN KEY (`address_id`)
    REFERENCES `Address` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Event_EventGroup1`
    FOREIGN KEY (`event_sequence_id`)
    REFERENCES `EventGroup` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Event_ExternalDataSource1`
    FOREIGN KEY (`external_data_source_id`)
    REFERENCES `ExternalDataSource` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `EventSeriesEvent`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EventSeriesEvent` (
  `event_id` INT UNSIGNED NOT NULL,
  `event_group_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`event_id`, `event_group_id`),
  INDEX `fk_EventEventGroup_EventGroup1_idx` (`event_group_id` ASC),
  INDEX `fk_EventEventGroup_Event1_idx` (`event_id` ASC),
  CONSTRAINT `fk_EventEventGroup_Event1`
    FOREIGN KEY (`event_id`)
    REFERENCES `Event` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_EventEventGroup_EventGroup1`
    FOREIGN KEY (`event_group_id`)
    REFERENCES `EventGroup` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `EventType`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EventType` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `activity_type_id` INT UNSIGNED NOT NULL,
  `description` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `description_UNIQUE` (`description` ASC),
  INDEX `fk_EventType_ActivityType1_idx` (`activity_type_id` ASC),
  CONSTRAINT `fk_EventType_ActivityType1`
    FOREIGN KEY (`activity_type_id`)
    REFERENCES `ActivityType` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `EventActivity`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EventActivity` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  `scheduled_start` DATETIME NULL,
  `entrants` INT UNSIGNED NULL,
  `event_id` INT UNSIGNED NOT NULL,
  `event_type_id` INT UNSIGNED NOT NULL,
  `external_identifier` VARCHAR(45) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_EventActivity_Event1_idx` (`event_id` ASC),
  INDEX `fk_EventActivity_EventType1_idx` (`event_type_id` ASC),
  CONSTRAINT `fk_EventActivity_Event1`
    FOREIGN KEY (`event_id`)
    REFERENCES `Event` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_EventActivity_EventType1`
    FOREIGN KEY (`event_type_id`)
    REFERENCES `EventType` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `CardioEventActivity`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CardioEventActivity` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `event_activity_id` INT UNSIGNED NOT NULL,
  `distance_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_CardioEventActivity_EventActivity1_idx` (`event_activity_id` ASC),
  INDEX `fk_CardioEventActivity_Distance1_idx` (`distance_id` ASC),
  CONSTRAINT `fk_CardioEventActivity_EventActivity1`
    FOREIGN KEY (`event_activity_id`)
    REFERENCES `EventActivity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_CardioEventActivity_Distance1`
    FOREIGN KEY (`distance_id`)
    REFERENCES `Distance` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `EventParticipant`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EventParticipant` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `registration_number` VARCHAR(20) NULL,
  `age` TINYINT UNSIGNED NULL,
  `person_id` INT UNSIGNED NOT NULL,
  `event_activity_id` INT UNSIGNED NOT NULL,
  `gender_id` INT UNSIGNED NULL,
  `division_id` INT UNSIGNED NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_EventParticipant_Person1_idx` (`person_id` ASC),
  INDEX `fk_EventParticipant_EventActivity1_idx` (`event_activity_id` ASC),
  INDEX `fk_EventParticipant_Gender1_idx` (`gender_id` ASC),
  INDEX `fk_EventParticipant_Division1_idx` (`division_id` ASC),
  CONSTRAINT `fk_EventParticipant_Person1`
    FOREIGN KEY (`person_id`)
    REFERENCES `Person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_EventParticipant_EventActivity1`
    FOREIGN KEY (`event_activity_id`)
    REFERENCES `EventActivity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_EventParticipant_Gender1`
    FOREIGN KEY (`gender_id`)
    REFERENCES `Gender` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_EventParticipant_Division1`
    FOREIGN KEY (`division_id`)
    REFERENCES `Division` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `EventPlacementPartition`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EventPlacementPartition` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `event_activity_id` INT UNSIGNED NOT NULL,
  `division_id` INT UNSIGNED NULL,
  `gender_id` INT UNSIGNED NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_EventPlacementPartition_EventActivity1_idx` (`event_activity_id` ASC),
  INDEX `fk_EventPlacementPartition_Division1_idx` (`division_id` ASC),
  INDEX `fk_EventPlacementPartition_Gender1_idx` (`gender_id` ASC),
  CONSTRAINT `fk_EventPlacementPartition_EventActivity1`
    FOREIGN KEY (`event_activity_id`)
    REFERENCES `EventActivity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_EventPlacementPartition_Division1`
    FOREIGN KEY (`division_id`)
    REFERENCES `Division` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_EventPlacementPartition_Gender1`
    FOREIGN KEY (`gender_id`)
    REFERENCES `Gender` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `EventPlacement`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EventPlacement` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `place` MEDIUMINT UNSIGNED NOT NULL,
  `event_participant_id` INT UNSIGNED NOT NULL,
  `event_placement_partition_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_EventPlacement_EventParticipant1_idx` (`event_participant_id` ASC),
  INDEX `fk_EventPlacement_EventPlacementPartition1_idx` (`event_placement_partition_id` ASC),
  CONSTRAINT `fk_EventPlacement_EventParticipant1`
    FOREIGN KEY (`event_participant_id`)
    REFERENCES `EventParticipant` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_EventPlacement_EventPlacementPartition1`
    FOREIGN KEY (`event_placement_partition_id`)
    REFERENCES `EventPlacementPartition` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `CardioEventParticipant`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CardioEventParticipant` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `event_participant_id` INT UNSIGNED NOT NULL,
  `cardio_activity_result_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_CardioEventParticipant_EventParticipant1_idx` (`event_participant_id` ASC),
  INDEX `fk_CardioEventParticipant_CardioActivityResult1_idx` (`cardio_activity_result_id` ASC),
  CONSTRAINT `fk_CardioEventParticipant_EventParticipant1`
    FOREIGN KEY (`event_participant_id`)
    REFERENCES `EventParticipant` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_CardioEventParticipant_CardioActivityResult1`
    FOREIGN KEY (`cardio_activity_result_id`)
    REFERENCES `CardioActivityResult` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Goal`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Goal` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `owner_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `definition` JSON NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Goal_User1_idx` (`owner_id` ASC),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC),
  CONSTRAINT `fk_Goal_User1`
    FOREIGN KEY (`owner_id`)
    REFERENCES `User` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `UserGoal`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `UserGoal` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `subscribed` ENUM('Y', 'N') NOT NULL DEFAULT 'N',
  `goal_id` INT UNSIGNED NOT NULL,
  `user_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_UserGoal_Goal1_idx` (`goal_id` ASC),
  INDEX `fk_UserGoal_User1_idx` (`user_id` ASC),
  CONSTRAINT `fk_UserGoal_Goal1`
    FOREIGN KEY (`goal_id`)
    REFERENCES `Goal` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_UserGoal_User1`
    FOREIGN KEY (`user_id`)
    REFERENCES `User` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `UserGoalFulfillment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `UserGoalFulfillment` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_goal_id` INT UNSIGNED NOT NULL,
  `date` DATE NOT NULL,
  `is_current` ENUM('Y', 'N') NULL DEFAULT 'Y',
  PRIMARY KEY (`id`),
  INDEX `fk_UserGoalFulfillment_UserGoal1_idx` (`user_goal_id` ASC),
  CONSTRAINT `fk_UserGoalFulfillment_UserGoal1`
    FOREIGN KEY (`user_goal_id`)
    REFERENCES `UserGoal` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `UserGoalFulfillmentWorkout`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `UserGoalFulfillmentWorkout` (
  `user_goal_fulfillment_id` INT UNSIGNED NOT NULL,
  `workout_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`user_goal_fulfillment_id`, `workout_id`),
  INDEX `fk_UserGoalFulfillmentWorkout_Workout1_idx` (`workout_id` ASC),
  INDEX `fk_UserGoalFulfillmentWorkout_UserGoalFulfillment1_idx` (`user_goal_fulfillment_id` ASC),
  CONSTRAINT `fk_UserGoalFulfillmentWorkout_UserGoalFulfillment1`
    FOREIGN KEY (`user_goal_fulfillment_id`)
    REFERENCES `UserGoalFulfillment` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_UserGoalFulfillmentWorkout_Workout1`
    FOREIGN KEY (`workout_id`)
    REFERENCES `Workout` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `UserGoalFulfillmentActivitySet`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `UserGoalFulfillmentActivitySet` (
  `user_goal_fulfillment_id` INT UNSIGNED NOT NULL,
  `activity_set_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`user_goal_fulfillment_id`, `activity_set_id`),
  INDEX `fk_UserGoalFulfillmentActivitySet_ActivitySet1_idx` (`activity_set_id` ASC),
  INDEX `fk_UserGoalFulfillmentActivitySet_UserGoalFulfillment1_idx` (`user_goal_fulfillment_id` ASC),
  CONSTRAINT `fk_UserGoalFulfillmentActivitySet_UserGoalFulfillment1`
    FOREIGN KEY (`user_goal_fulfillment_id`)
    REFERENCES `UserGoalFulfillment` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_UserGoalFulfillmentActivitySet_ActivitySet1`
    FOREIGN KEY (`activity_set_id`)
    REFERENCES `ActivitySet` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `UserGoalFulfillmentActivity`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `UserGoalFulfillmentActivity` (
  `user_goal_fulfillment_id` INT UNSIGNED NOT NULL,
  `activity_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`user_goal_fulfillment_id`, `activity_id`),
  INDEX `fk_UserGoalFulfillmentActivity_Activity1_idx` (`activity_id` ASC),
  INDEX `fk_UserGoalFulfillmentActivity_UserGoalFulfillment1_idx` (`user_goal_fulfillment_id` ASC),
  CONSTRAINT `fk_UserGoalFulfillmentActivity_UserGoalFulfillment1`
    FOREIGN KEY (`user_goal_fulfillment_id`)
    REFERENCES `UserGoalFulfillment` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_UserGoalFulfillmentActivity_Activity1`
    FOREIGN KEY (`activity_id`)
    REFERENCES `Activity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `VisibilityType`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `VisibilityType` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `description_UNIQUE` (`description` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `UserEventActivity`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `UserEventActivity` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `event_activity_id` INT UNSIGNED NOT NULL,
  `visibility_type_id` INT UNSIGNED NOT NULL,
  `registration_date` DATE NULL,
  `registration_number` VARCHAR(20) NULL,
  `fee` DECIMAL(6,2) NULL,
  `fundraising_requirement` DECIMAL(6,2) NULL,
  `event_participant_id` INT UNSIGNED NULL,
  `activity_id` INT UNSIGNED NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_UserEventActivity_User1_idx` (`user_id` ASC),
  INDEX `fk_UserEventActivity_EventActivity1_idx` (`event_activity_id` ASC),
  INDEX `fk_UserEventActivity_VisibilityType1_idx` (`visibility_type_id` ASC),
  INDEX `fk_UserEventActivity_EventParticipant1_idx` (`event_participant_id` ASC),
  INDEX `fk_UserEventActivity_Activity1_idx` (`activity_id` ASC),
  CONSTRAINT `fk_UserEventActivity_User1`
    FOREIGN KEY (`user_id`)
    REFERENCES `User` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_UserEventActivity_EventActivity1`
    FOREIGN KEY (`event_activity_id`)
    REFERENCES `EventActivity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_UserEventActivity_VisibilityType1`
    FOREIGN KEY (`visibility_type_id`)
    REFERENCES `VisibilityType` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_UserEventActivity_EventParticipant1`
    FOREIGN KEY (`event_participant_id`)
    REFERENCES `EventParticipant` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_UserEventActivity_Activity1`
    FOREIGN KEY (`activity_id`)
    REFERENCES `Activity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Donation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Donation` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `date` DATE NOT NULL,
  `amount` DECIMAL(6,2) UNSIGNED NOT NULL,
  `user_event_activity_id` INT UNSIGNED NOT NULL,
  `person_id` INT UNSIGNED NOT NULL,
  `address_id` INT UNSIGNED NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Donation_UserEventActivity1_idx` (`user_event_activity_id` ASC),
  INDEX `fk_Donation_Person1_idx` (`person_id` ASC),
  INDEX `fk_Donation_Address1_idx` (`address_id` ASC),
  CONSTRAINT `fk_Donation_UserEventActivity1`
    FOREIGN KEY (`user_event_activity_id`)
    REFERENCES `UserEventActivity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Donation_Person1`
    FOREIGN KEY (`person_id`)
    REFERENCES `Person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Donation_Address1`
    FOREIGN KEY (`address_id`)
    REFERENCES `Address` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Data for table `Gender`
-- -----------------------------------------------------
INSERT INTO `Gender` (`id`, `name`, `abbreviation`) VALUES 
(1, 'Male', 'M'),
(2, 'Female', 'F');

-- -----------------------------------------------------
-- Data for table `UnitOfMeasure`
-- -----------------------------------------------------
INSERT INTO `UnitOfMeasure` (`id`, `name`, `abbreviation`, `normalization_factor`, `normal_unit_id`) VALUES 
(1, 'mile', 'mi', 1, NULL),
(2, 'kilometer', 'km', 0.621371, 1),
(3, 'miles per hour', 'mph', 1, NULL),
(4, 'kilometers per hour', 'kph', 0.621371, 3),
(5, 'yard', 'yd', 0.000568182, 1);

-- -----------------------------------------------------
-- Data for table `ActivityType`
-- -----------------------------------------------------
INSERT INTO `ActivityType` (`id`, `description`, `is_cardio`, `is_lift`, `is_hold`) VALUES 
(1, 'Run', 'Y', 'N', 'N'),
(2, 'Ride', 'Y', 'N', 'N'),
(3, 'Kayak', 'Y', 'N', 'N'),
(4, 'Walk', 'Y', 'N', 'N'),
(5, 'Treadmill', 'Y', 'N', 'N');

-- -----------------------------------------------------
-- Data for table `EventType`
-- -----------------------------------------------------
INSERT INTO `EventType` (`id`, `activity_type_id`, `description`) VALUES 
(1, 1, 'Road Race'),
(2, 2, 'Charity Ride'),
(3, 2, 'Group Ride'),
(4, 1, 'Group Run'),
(5, 1, 'Cross Country Race'),
(6, 1, 'Obstacle Course Race'),
(7, 1, 'Virtual Run'),
(8, 1, 'Fun Run');

-- -----------------------------------------------------
-- Data for table `ExternalDataSource`
-- -----------------------------------------------------
INSERT INTO `ExternalDataSource` (`id`, `name`, `import_class`, `base_url`) VALUES 
(1, 'RaceWire', 'RaceWire',''),
(2, 'iResultsLive', 'iResultsLive','http://www.iresultslive.com/'),
(3, 'MilenniumRunning', 'MilenniumRunning','http://www.millenniumrunning.com/'),
(4, 'MTEC', 'MTEC','https://www.mtecresults.com/'),
(5, 'RunKeeper', 'RunKeeper','https://www.runkeeper.com/');

-- -----------------------------------------------------
-- Data for table `VisibilityType`
-- -----------------------------------------------------
INSERT INTO `VisibilityType` (`id`, `description`) VALUES 
(1, 'Only Me'),
(2, 'Everyone');

-- -----------------------------------------------------
-- Migrate data from old tables to new
-- -----------------------------------------------------
INSERT INTO `Address` (`id`,`street1`,`street2`,`city`,`state`,`zip`,`country`,`phone`,`email`) 
  SELECT `id`,`street1`,`street2`,`city`,`state`,`zip`,`country`,`phone`,`email` 
  FROM `mig_address`;

INSERT INTO `Distance` (`id`,`value`,`unit_of_measure_id`) 
  SELECT `id`,`value`,`uom` 
  FROM `mig_distance`;

INSERT INTO `Division` (`id`,`name`) 
  SELECT `id`,`name` 
  FROM `mig_division`;

INSERT INTO `Location` (`id`,`latitude`,`longitude`) 
  SELECT `id`,`latitude`,`longitude` 
  FROM `mig_location`;

INSERT INTO `Person` (`id`,`firstname`,`lastname`) 
  SELECT `id`,`first_name`,`last_name` 
  FROM `mig_person`;

INSERT INTO `User` (`id`,`username`,`person_id`) 
  SELECT `id`,`username`,`person_id` 
  FROM `mig_user`;

CREATE TABLE `mig_activity_pk` (`id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, `activity_id` INT UNSIGNED NOT NULL);
INSERT INTO `mig_activity_pk` (`activity_id`) SELECT `id` FROM `mig_activity` WHERE `user_id` IS NOT NULL;
 
INSERT INTO `Workout` (`id`,`user_id`,`date`,`name`) 
  SELECT pk.`id`,a.`user_id`,CAST(a.`start_time` AS DATE),'Workout' 
  FROM `mig_activity` a
  JOIN `mig_activity_pk` pk
  	ON a.`id` = pk.`activity_id`
  WHERE a.`user_id` IS NOT NULL;

INSERT INTO `Activity` (`id`,`workout_id`,`whole_activity_id`,`start_time`,`note`,`external_data_source_id`,`external_identifier`) 
  SELECT pk.`id`,pk.`id`,a.`whole_activity_id`,a.`start_time`,COALESCE(a.`note`,''),e.`id`,r.`reference_id` 
  FROM `mig_activity` a
  JOIN `mig_activity_pk` pk
  	ON a.`id` = pk.`activity_id`
  LEFT JOIN `mig_activity_reference` r
    ON a.`id` = r.`activity_id`
  LEFT JOIN `ExternalDataSource` e
    ON r.`import_class` = e.`import_class`
  WHERE a.`user_id` IS NOT NULL;

INSERT INTO `ActivitySet` (`id`,`num`,`activity_id`) 
  SELECT pk.`id`,1,pk.`id` 
  FROM `mig_activity` a
  JOIN `mig_activity_pk` pk
  	ON a.`id` = pk.`activity_id`
  WHERE a.`user_id` IS NOT NULL;

INSERT INTO `CardioActivitySet` (`id`,`activity_set_id`,`distance_id`,`heart_rate`,`weight`,`cardio_activity_result_id`) 
  SELECT pk.`id`,pk.`id`,a.`distance_id`,r.`heart_rate`,0,r.`id` 
  FROM `mig_activity` a
  JOIN `mig_activity_pk` pk
  	ON a.`id` = pk.`activity_id`
  JOIN `mig_result` r
    ON a.`result_id` = r.`id`
  WHERE a.`user_id` IS NOT NULL;

INSERT INTO `CardioActivityResult` (`id`,`gross_time`,`net_time`,`pace`,`speed`) 
  SELECT `id`,`gross_time`,`net_time`,`pace`,`speed`
  FROM `mig_result`;

INSERT INTO `OutdoorActivitySet` (`id`,`activity_set_id`,`temperature`) 
  SELECT pk.`id`,pk.`id`,a.`temperature` 
  FROM `mig_activity` a
  JOIN `mig_activity_pk` pk
  	ON a.`id` = pk.`activity_id`
  WHERE a.`user_id` IS NOT NULL;

INSERT INTO `ActivityPoint` (`outdoor_activity_id`,`timestamp`,`location_id`) 
  SELECT `activity_id`,`timestamp`,`location_id` 
  FROM `mig_activity_point`;
 
 INSERT INTO `EventGroup` (`id`,`name`,`year`,`url`)
  SELECT 19+`id`,`name`,`year`,`url` FROM `mig_event_series`
    UNION
  SELECT DISTINCT mes.`id`,mg.`name`,NULL,mes.`url` FROM `mig_event_sequence` mes
  JOIN `mig_event_group` mg
    ON mg.`event_sequence_id` =mes.`id`
  WHERE mg.`name` <> 'Memory Ride';

INSERT INTO `Event` (`id`,`name`,`year`,`url`,`address_id`,`event_sequence_id`,`external_data_source_id`,`external_identifier`)
  WITH t AS (SELECT mer.`event_reference_type_id`,mer.`ref_num`,me.`event_group_id` FROM `mig_event` me JOIN `mig_event_reference` mer ON me.`id` =mer.`event_id`)
  SELECT eg.`id`,eg.`name`,eg.`year`,eg.`url`,eg.`address_id`,eg.`event_sequence_id`,
  (SELECT t.`event_reference_type_id` FROM t WHERE t.`event_group_id` = eg.`id`),
  (SELECT t.`ref_num` FROM t WHERE t.`event_group_id` = eg.`id`)
  FROM `mig_event_group` eg;
 
INSERT INTO `EventSeriesEvent` (`event_id`,`event_group_id`)
  SELECT `event_group_id`, 19+`event_series_id`
  FROM `mig_event_group_series`;
 
INSERT INTO `EventActivity` (`id`,`name`,`scheduled_start`,`entrants`,`event_id`,`event_type_id`,`external_identifier`) 
  SELECT e.`id`,e.`name`,e.`scheduled_start`,e.`entrants`,e.`event_group_id`,e.`event_type_id`,mer.`sub_ref_num`
  FROM `mig_event` e
  LEFT JOIN `mig_event_reference` mer
    ON e.`id` = mer.`event_id`;
  
INSERT INTO `CardioEventActivity` (`id`,`event_activity_id`,`distance_id`) 
  SELECT `id`,`id`,`distance_id`
  FROM `mig_event`;
 
INSERT INTO `EventParticipant` (`id`,`registration_number`,`age`,`person_id`,`event_activity_id`,`gender_id`,`division_id`) 
  SELECT p.`id`,p.`bib_no`,p.`age`,p.`person_id`,a.`event_id`,p.`gender_id`,p.`division_id`
  FROM `mig_participant` p
  JOIN `mig_activity` a
    ON p.`result_id` = a.`result_id`;

INSERT INTO `CardioEventParticipant` (`event_participant_id`, `cardio_activity_result_id`) 
  SELECT `id`,`result_id`
  FROM `mig_participant`;

INSERT INTO `EventPlacement` (`id`,`place`,`event_participant_id`,`event_placement_partition_id`) 
  SELECT r.`id`,r.`place`,p.`id`,r.`event_result_group_id`
  FROM `mig_event_result` r
  JOIN `mig_participant` p
 	ON r.`result_id` = p.`result_id`;

INSERT INTO `EventPlacementPartition` (`id`,`event_activity_id`,`gender_id`,`division_id`)
  SELECT `id`,`event_id`,`gender_id`,`division_id`
  FROM `mig_event_result_group`;

INSERT INTO `UserEventActivity` (`user_id`,`event_activity_id`,`visibility_type_id`,`event_participant_id`, `registration_date`,`registration_number`,`fee`,`fundraising_requirement`,`activity_id`) 
  WITH t AS (
    SELECT p.*, a.`event_id`
    FROM `mig_participant` p
    JOIN `mig_activity` a
  	  ON p.`result_id` = a.`result_id`
  )
  SELECT 
    mer.`user_id`,mer.`event_id`, 
	CASE mer.`is_public` WHEN 'Y' THEN 2 ELSE 1 END AS `visibility_type_id`,t.`id`,
	CASE mer.`registered` WHEN 'Y' THEN CAST(e.`scheduled_start` AS DATE) ELSE NULL END AS `registration_date`,
	mer.`bib_no`,mer.`fee`,mer.`fundraising_minimum`,pk.`id`
  FROM `mig_event_registration` mer
  JOIN `mig_user` u
    ON mer.`user_id` = u.`id`
  JOIN `mig_event` e
  	ON mer.`event_id` = e.`id`
  LEFT JOIN `mig_activity` a
  	ON mer.`user_id` = a.`user_id`
  	AND mer.`event_id` = a.`event_id`
  LEFT JOIN `mig_activity_pk` pk
  	ON a.`id` = pk.`activity_id`
  LEFT JOIN t
  	ON t.`person_id` = u.`person_id`
  	AND t.`event_id` = mer.`event_id`;
  
INSERT INTO `Donation` (`id`,`date`,`amount`,`user_event_activity_id`,`person_id`,`address_id`) 
  SELECT  d.`id`,d.`date`,d.`amount`,uea.`id`,d.`person_id`,d.`address_id`
  FROM `mig_donation` d
  JOIN `UserEventActivity` uea
    ON d.`user_id` = uea.`user_id`
    AND d.`event_id` = uea.`event_activity_id`;

   
-- -----------------------------------------------------
-- Drop old tables
-- -----------------------------------------------------
DROP TABLE `mig_activity`;
DROP TABLE `mig_activity_point`;
DROP TABLE `mig_activity_reference`;
DROP TABLE `mig_activity_type`;
DROP TABLE `mig_address`;
DROP TABLE `mig_dimension`;
DROP TABLE `mig_distance`;
DROP TABLE `mig_division`;
DROP TABLE `mig_donation`;
DROP TABLE `mig_event`;
DROP TABLE `mig_event_group`;
DROP TABLE `mig_event_group_series`;
DROP TABLE `mig_event_reference`;
DROP TABLE `mig_event_reference_type`;
DROP TABLE `mig_event_registration`;
DROP TABLE `mig_event_result`;
DROP TABLE `mig_event_result_group`;
DROP TABLE `mig_event_sequence`;
DROP TABLE `mig_event_series`;
DROP TABLE `mig_event_type`;
DROP TABLE `mig_gender`;
DROP TABLE `mig_goal`;
DROP TABLE `mig_goal_comparator`;
DROP TABLE `mig_goal_span`;
DROP TABLE `mig_location`;
DROP TABLE `mig_participant`;
DROP TABLE `mig_person`;
DROP TABLE `mig_result`;
DROP TABLE `mig_unit_of_measure`;
DROP TABLE `mig_user`;
DROP TABLE `mig_user_goal`;
DROP TABLE `mig_user_goal_fulfillment`;
DROP TABLE `mig_user_goal_fulfillment_activity`;
DROP TABLE `mig_activity_pk`;

-- -----------------------------------------------------
-- Re-enable constraints
-- -----------------------------------------------------
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

COMMIT;

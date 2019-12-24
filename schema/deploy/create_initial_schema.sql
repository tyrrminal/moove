-- Deploy moove:create_initial_schema to mysql

BEGIN;

SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

--
-- Table structure for table `activity`
--

DROP TABLE IF EXISTS `activity`;
CREATE TABLE `activity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `activity_type_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `distance_id` int(11) NOT NULL,
  `result_id` int(11) DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  `temperature` decimal(4,1) DEFAULT NULL,
  `note` mediumtext DEFAULT NULL,
  `whole_activity_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_activity_activity_type1_idx` (`activity_type_id`),
  KEY `fk_activity_result1_idx` (`result_id`),
  KEY `fk_activity_event1_idx` (`event_id`),
  KEY `fk_activity_distance1_idx` (`distance_id`),
  KEY `fk_activity_activity1_idx` (`whole_activity_id`),
  KEY `fk_activity_user1_idx` (`user_id`),
  CONSTRAINT `fk_activity_activity1` FOREIGN KEY (`whole_activity_id`) REFERENCES `activity` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_activity_activity_type1` FOREIGN KEY (`activity_type_id`) REFERENCES `activity_type` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_activity_distance1` FOREIGN KEY (`distance_id`) REFERENCES `distance` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_activity_event1` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_activity_result1` FOREIGN KEY (`result_id`) REFERENCES `result` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_activity_user1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=61760 DEFAULT CHARSET=utf8;

--
-- Table structure for table `activity_point`
--

DROP TABLE IF EXISTS `activity_point`;
CREATE TABLE `activity_point` (
  `activity_id` int(11) NOT NULL,
  `location_id` int(11) NOT NULL,
  `timestamp` datetime NOT NULL,
  PRIMARY KEY (`activity_id`,`location_id`),
  KEY `fk_activity_location_location1_idx` (`location_id`),
  KEY `fk_activity_location_activity1_idx` (`activity_id`),
  CONSTRAINT `fk_activity_location_activity1` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_activity_location_location1` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `activity_reference`
--

DROP TABLE IF EXISTS `activity_reference`;
CREATE TABLE `activity_reference` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `activity_id` int(11) NOT NULL,
  `reference_id` varchar(100) NOT NULL,
  `import_class` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_activity_reference_activity_id_idx` (`activity_id`),
  CONSTRAINT `fk_activity_reference_activity_id` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=783 DEFAULT CHARSET=utf8;

--
-- Table structure for table `activity_type`
--

DROP TABLE IF EXISTS `activity_type`;
CREATE TABLE `activity_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `description_UNIQUE` (`description`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

--
-- Table structure for table `address`
--

DROP TABLE IF EXISTS `address`;
CREATE TABLE `address` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `street1` varchar(45) DEFAULT NULL,
  `street2` varchar(45) DEFAULT NULL,
  `city` varchar(45) DEFAULT NULL,
  `state` varchar(45) DEFAULT NULL,
  `zip` varchar(10) DEFAULT NULL,
  `phone` varchar(14) DEFAULT NULL,
  `country` varchar(45) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2435 DEFAULT CHARSET=utf8;

--
-- Table structure for table `dimension`
--

DROP TABLE IF EXISTS `dimension`;
CREATE TABLE `dimension` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `description_UNIQUE` (`description`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `distance`
--

DROP TABLE IF EXISTS `distance`;
CREATE TABLE `distance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` decimal(7,3) NOT NULL,
  `uom` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `distance_value_uom_uniq_idx` (`value`,`uom`),
  KEY `fk_distance_unit_of_measure1_idx` (`uom`),
  CONSTRAINT `fk_distance_unit_of_measure1` FOREIGN KEY (`uom`) REFERENCES `unit_of_measure` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=512 DEFAULT CHARSET=utf8;

--
-- Table structure for table `division`
--

DROP TABLE IF EXISTS `division`;
CREATE TABLE `division` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=128 DEFAULT CHARSET=utf8;

--
-- Table structure for table `donation`
--

DROP TABLE IF EXISTS `donation`;
CREATE TABLE `donation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `amount` decimal(6,2) NOT NULL,
  `date` date NOT NULL,
  `person_id` int(11) NOT NULL,
  `address_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_donation_event_registration1_idx` (`event_id`,`user_id`),
  KEY `fk_donation_person1_idx` (`person_id`),
  KEY `fk_donation_location1_idx` (`address_id`),
  CONSTRAINT `fk_donation_event_registration1` FOREIGN KEY (`event_id`, `user_id`) REFERENCES `event_registration` (`event_id`, `user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_donation_location1` FOREIGN KEY (`address_id`) REFERENCES `address` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_donation_person1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=646 DEFAULT CHARSET=utf8;

--
-- Table structure for table `event`
--

DROP TABLE IF EXISTS `event`;
CREATE TABLE `event` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_group_id` int(11) NOT NULL,
  `name` varchar(45) DEFAULT NULL,
  `scheduled_start` datetime NOT NULL,
  `entrants` int(10) unsigned DEFAULT NULL,
  `event_type_id` int(11) NOT NULL,
  `distance_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_event_event_type1_idx` (`event_type_id`),
  KEY `fk_event_distance1_idx` (`distance_id`),
  KEY `fk_event_event_group1_idx` (`event_group_id`),
  CONSTRAINT `fk_event_distance1` FOREIGN KEY (`distance_id`) REFERENCES `distance` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_event_event_group1` FOREIGN KEY (`event_group_id`) REFERENCES `event_group` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_event_event_type1` FOREIGN KEY (`event_type_id`) REFERENCES `event_type` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8;

--
-- Table structure for table `event_group`
--

DROP TABLE IF EXISTS `event_group`;
CREATE TABLE `event_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `year` int(11) NOT NULL,
  `url` varchar(512) DEFAULT NULL,
  `address_id` int(11) NOT NULL,
  `event_sequence_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_event_group_address1_idx` (`address_id`),
  KEY `fk_event_group_event_sequence1_idx` (`event_sequence_id`),
  CONSTRAINT `fk_event_group_address1` FOREIGN KEY (`address_id`) REFERENCES `address` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_event_group_event_sequence1` FOREIGN KEY (`event_sequence_id`) REFERENCES `event_sequence` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8;

--
-- Table structure for table `event_group_series`
--

DROP TABLE IF EXISTS `event_group_series`;
CREATE TABLE `event_group_series` (
  `event_group_id` int(11) NOT NULL,
  `event_series_id` int(11) NOT NULL,
  PRIMARY KEY (`event_group_id`,`event_series_id`),
  KEY `fk_event_series1_idx` (`event_series_id`),
  CONSTRAINT `fk_event_group1` FOREIGN KEY (`event_group_id`) REFERENCES `event_group` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_event_series1` FOREIGN KEY (`event_series_id`) REFERENCES `event_series` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `event_reference`
--

DROP TABLE IF EXISTS `event_reference`;
CREATE TABLE `event_reference` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` int(11) NOT NULL,
  `event_reference_type_id` int(11) NOT NULL,
  `referenced_name` varchar(100) NOT NULL,
  `ref_num` varchar(45) NOT NULL,
  `sub_ref_num` varchar(45) DEFAULT NULL,
  `imported` enum('Y','N') NOT NULL DEFAULT 'N',
  PRIMARY KEY (`id`),
  KEY `fk_event_reference_event1_idx` (`event_id`),
  KEY `fk_event_reference_event_reference_type1_idx` (`event_reference_type_id`),
  CONSTRAINT `fk_event_reference_event1` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_event_reference_event_reference_type1` FOREIGN KEY (`event_reference_type_id`) REFERENCES `event_reference_type` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8;

--
-- Table structure for table `event_reference_type`
--

DROP TABLE IF EXISTS `event_reference_type`;
CREATE TABLE `event_reference_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `description_UNIQUE` (`description`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Table structure for table `event_registration`
--

DROP TABLE IF EXISTS `event_registration`;
CREATE TABLE `event_registration` (
  `event_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `fee` decimal(6,2) DEFAULT NULL,
  `fundraising_minimum` decimal(6,2) DEFAULT NULL,
  `registered` enum('Y','P','N') DEFAULT 'N',
  `bib_no` int(11) DEFAULT NULL,
  `is_public` enum('Y','N') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`event_id`,`user_id`),
  KEY `fk_user_has_event_event1_idx` (`event_id`),
  KEY `fk_user_has_event_user_idx` (`user_id`),
  CONSTRAINT `fk_user_has_event_event1` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_has_event_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `event_result`
--

DROP TABLE IF EXISTS `event_result`;
CREATE TABLE `event_result` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `result_id` int(11) NOT NULL,
  `place` int(11) NOT NULL,
  `event_result_group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_event_result_result1_idx` (`result_id`),
  KEY `fk_event_result_event_result_group1_idx` (`event_result_group_id`),
  CONSTRAINT `fk_event_result_event_result_group1` FOREIGN KEY (`event_result_group_id`) REFERENCES `event_result_group` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_event_result_result1` FOREIGN KEY (`result_id`) REFERENCES `result` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=163768 DEFAULT CHARSET=utf8;

--
-- Table structure for table `event_result_group`
--

DROP TABLE IF EXISTS `event_result_group`;
CREATE TABLE `event_result_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` int(11) NOT NULL,
  `gender_id` int(11) DEFAULT NULL,
  `division_id` int(11) DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_event_gender_division_idx1` (`event_id`,`gender_id`,`division_id`),
  KEY `fk_event_result_group_event1_idx` (`event_id`),
  KEY `fk_event_result_group_gender1_idx` (`gender_id`),
  KEY `fk_event_result_group_division1_idx` (`division_id`),
  CONSTRAINT `fk_event_result_group_division1` FOREIGN KEY (`division_id`) REFERENCES `division` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_event_result_group_event1` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_event_result_group_gender1` FOREIGN KEY (`gender_id`) REFERENCES `gender` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=694 DEFAULT CHARSET=utf8;

--
-- Table structure for table `event_sequence`
--

DROP TABLE IF EXISTS `event_sequence`;
CREATE TABLE `event_sequence` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8;

--
-- Table structure for table `event_series`
--

DROP TABLE IF EXISTS `event_series`;
CREATE TABLE `event_series` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `year` int(11) NOT NULL,
  `url` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_year_uniq_idx` (`name`,`year`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

--
-- Table structure for table `event_type`
--

DROP TABLE IF EXISTS `event_type`;
CREATE TABLE `event_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `activity_type_id` int(11) NOT NULL,
  `description` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `description_UNIQUE` (`description`),
  KEY `fk_event_type_activity_type1_idx` (`activity_type_id`),
  CONSTRAINT `fk_event_type_activity_type1` FOREIGN KEY (`activity_type_id`) REFERENCES `activity_type` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

--
-- Table structure for table `gender`
--

DROP TABLE IF EXISTS `gender`;
CREATE TABLE `gender` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `description_UNIQUE` (`description`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

--
-- Table structure for table `goal`
--

DROP TABLE IF EXISTS `goal`;
CREATE TABLE `goal` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `activity_type_id` int(11) NOT NULL,
  `event_only` enum('Y','N') NOT NULL DEFAULT 'N',
  `dimension_id` int(11) NOT NULL,
  `goal_comparator_id` int(11) NOT NULL,
  `goal_span_id` int(11) DEFAULT NULL,
  `min_distance_id` int(11) DEFAULT NULL,
  `max_distance_id` int(11) DEFAULT NULL,
  `min_date` date DEFAULT NULL,
  `max_date` date DEFAULT NULL,
  `time` time DEFAULT NULL,
  `distance_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`),
  KEY `fk_goal_activity_type_idx` (`activity_type_id`),
  KEY `fk_goal_dimension1_idx` (`dimension_id`),
  KEY `fk_goal_goal_comparator1_idx` (`goal_comparator_id`),
  KEY `fk_goal_goal_span1_idx` (`goal_span_id`),
  KEY `fk_goal_distance1_idx` (`distance_id`),
  KEY `fk_goal_distance2_idx` (`min_distance_id`),
  KEY `fk_goal_distance3_idx` (`max_distance_id`),
  CONSTRAINT `fk_goal_activity_type` FOREIGN KEY (`activity_type_id`) REFERENCES `activity_type` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_goal_dimension1` FOREIGN KEY (`dimension_id`) REFERENCES `dimension` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_goal_distance1` FOREIGN KEY (`distance_id`) REFERENCES `distance` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_goal_distance2` FOREIGN KEY (`min_distance_id`) REFERENCES `distance` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_goal_distance3` FOREIGN KEY (`max_distance_id`) REFERENCES `distance` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_goal_goal_comparator1` FOREIGN KEY (`goal_comparator_id`) REFERENCES `goal_comparator` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_goal_goal_span1` FOREIGN KEY (`goal_span_id`) REFERENCES `goal_span` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `goal_comparator`
--

DROP TABLE IF EXISTS `goal_comparator`;
CREATE TABLE `goal_comparator` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `superlative` enum('Y','N') DEFAULT 'N',
  `operator` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `operator_UNIQUE` (`operator`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `goal_span`
--

DROP TABLE IF EXISTS `goal_span`;
CREATE TABLE `goal_span` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `description_UNIQUE` (`description`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
CREATE TABLE `location` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `latitude` decimal(9,6) NOT NULL,
  `longitude` decimal(9,6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=486308 DEFAULT CHARSET=utf8;

--
-- Table structure for table `participant`
--

DROP TABLE IF EXISTS `participant`;
CREATE TABLE `participant` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `result_id` int(11) NOT NULL,
  `bib_no` int(11) DEFAULT NULL,
  `division_id` int(11) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `person_id` int(11) NOT NULL,
  `gender_id` int(11) DEFAULT NULL,
  `address_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_participant_result1_idx` (`result_id`),
  KEY `fk_participant_division1_idx` (`division_id`),
  KEY `fk_participant_person1_idx` (`person_id`),
  KEY `fk_participant_gender1_idx` (`gender_id`),
  KEY `fk_participant_location1_idx` (`address_id`),
  CONSTRAINT `fk_participant_division1` FOREIGN KEY (`division_id`) REFERENCES `division` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_participant_gender1` FOREIGN KEY (`gender_id`) REFERENCES `gender` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_participant_location1` FOREIGN KEY (`address_id`) REFERENCES `address` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_participant_person1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_participant_result1` FOREIGN KEY (`result_id`) REFERENCES `result` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=58085 DEFAULT CHARSET=utf8;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
CREATE TABLE `person` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=58622 DEFAULT CHARSET=utf8;

--
-- Table structure for table `result`
--

DROP TABLE IF EXISTS `result`;
CREATE TABLE `result` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gross_time` time(1) DEFAULT NULL,
  `net_time` time(1) NOT NULL,
  `pace` time(1) DEFAULT NULL,
  `speed` decimal(7,3) GENERATED ALWAYS AS (1 / ((hour(`pace`) * 60 * 60 + minute(`pace`) * 60 + second(`pace`)) / (60 * 60))) VIRTUAL,
  `heart_rate` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=61761 DEFAULT CHARSET=utf8;

--
-- Table structure for table `unit_of_measure`
--

DROP TABLE IF EXISTS `unit_of_measure`;
CREATE TABLE `unit_of_measure` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dimension_id` int(11) NOT NULL,
  `uom` varchar(45) NOT NULL,
  `abbreviation` varchar(10) NOT NULL,
  `conversion_factor` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uom_UNIQUE` (`uom`),
  UNIQUE KEY `abbreviation_UNIQUE` (`abbreviation`),
  KEY `fk_uom_dimension1` (`dimension_id`),
  CONSTRAINT `fk_uom_dimension1` FOREIGN KEY (`dimension_id`) REFERENCES `dimension` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(45) NOT NULL,
  `person_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username_UNIQUE` (`username`),
  KEY `fk_user_person1_idx` (`person_id`),
  KEY `fk_user_location1_idx` (`location_id`),
  CONSTRAINT `fk_user_location1` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_person1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

--
-- Table structure for table `user_goal`
--

DROP TABLE IF EXISTS `user_goal`;
CREATE TABLE `user_goal` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `goal_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fk_user_goal_user_goal1_uniq` (`user_id`,`goal_id`),
  KEY `fk_user_goal_user1_idx` (`user_id`),
  KEY `fk_user_goal_goal1_idx` (`goal_id`),
  CONSTRAINT `fk_user_goal_goal1` FOREIGN KEY (`goal_id`) REFERENCES `goal` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_goal_user1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `user_goal_fulfillment`
--

DROP TABLE IF EXISTS `user_goal_fulfillment`;
CREATE TABLE `user_goal_fulfillment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_goal_id` int(11) NOT NULL,
  `date` datetime NOT NULL,
  `is_current` enum('Y','N') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`id`),
  KEY `fk_user_goal_fulfillment_user_goal1_idx` (`user_goal_id`),
  CONSTRAINT `fk_user_goal_fulfillment_user_goal1` FOREIGN KEY (`user_goal_id`) REFERENCES `user_goal` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=412 DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `user_goal_fulfillment_activity`
--

DROP TABLE IF EXISTS `user_goal_fulfillment_activity`;
CREATE TABLE `user_goal_fulfillment_activity` (
  `user_goal_fulfillment_id` int(11) NOT NULL,
  `activity_id` int(11) NOT NULL,
  PRIMARY KEY (`user_goal_fulfillment_id`,`activity_id`),
  KEY `fk_user_goal_fulfillment_has_activity_activity1_idx` (`activity_id`),
  KEY `fk_user_goal_fulfillment_has_activity_user_goal_fulfillment_idx` (`user_goal_fulfillment_id`),
  CONSTRAINT `fk_user_goal_fulfillment_has_activity_activity1` FOREIGN KEY (`activity_id`) REFERENCES `activity` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_goal_fulfillment_has_activity_user_goal_fulfillment1` FOREIGN KEY (`user_goal_fulfillment_id`) REFERENCES `user_goal_fulfillment` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `activity_type` (id,description) VALUES (1,'Run');
INSERT INTO `activity_type` (id,description) VALUES (2,'Ride');
INSERT INTO `activity_type` (id,description) VALUES (3,'Kayak');
INSERT INTO `activity_type` (id,description) VALUES (4,'Swim');
INSERT INTO `activity_type` (id,description) VALUES (5,'Walk');
INSERT INTO `activity_type` (id,description) VALUES (6,'Treadmill');

INSERT INTO `dimension` (id,description) VALUES (1,'distance');
INSERT INTO `dimension` (id,description) VALUES (2,'speed');
INSERT INTO `dimension` (id,description) VALUES (3,'time');
INSERT INTO `dimension` (id,description) VALUES (4,'pace');

INSERT INTO `event_reference_type` (id,description) VALUES (1,'RaceWire');
INSERT INTO `event_reference_type` (id,description) VALUES (2,'IResultsLive');
INSERT INTO `event_reference_type` (id,description) VALUES (3,'MillenniumRunning');
INSERT INTO `event_reference_type` (id,description) VALUES (4,'MTEC');

INSERT INTO `event_type` (id,activity_type_id,description) VALUES (1,1,'Road Race');
INSERT INTO `event_type` (id,activity_type_id,description) VALUES (2,2,'Charity Ride');
INSERT INTO `event_type` (id,activity_type_id,description) VALUES (3,2,'Group Ride');
INSERT INTO `event_type` (id,activity_type_id,description) VALUES (4,1,'Group Run');
INSERT INTO `event_type` (id,activity_type_id,description) VALUES (5,1,'Cross Country Race');
INSERT INTO `event_type` (id,activity_type_id,description) VALUES (6,1,'Obstacle Course Race');
INSERT INTO `event_type` (id,activity_type_id,description) VALUES (7,1,'Virtual Run');
INSERT INTO `event_type` (id,activity_type_id,description) VALUES (8,1,'Kids Fun Run');

INSERT INTO `gender` (id,description) VALUES (1,'M');
INSERT INTO `gender` (id,description) VALUES (2,'F');

INSERT INTO `goal_comparator` (id,superlative,operator) VALUES (1,'Y','maximum');
INSERT INTO `goal_comparator` (id,superlative,operator) VALUES (2,'Y','minimum');
INSERT INTO `goal_comparator` (id,superlative,operator) VALUES (3,'N','<');
INSERT INTO `goal_comparator` (id,superlative,operator) VALUES (4,'N','>');
INSERT INTO `goal_comparator` (id,superlative,operator) VALUES (5,'N','<=');
INSERT INTO `goal_comparator` (id,superlative,operator) VALUES (6,'N','>=');
INSERT INTO `goal_comparator` (id,superlative,operator) VALUES (7,'N','=');

INSERT INTO `unit_of_measure` (id,dimension_id,uom,abbreviation,conversion_factor) VALUES (1,1,'mile','mi','1');
INSERT INTO `unit_of_measure` (id,dimension_id,uom,abbreviation,conversion_factor) VALUES (2,1,'kilometer','km','0.621371');
INSERT INTO `unit_of_measure` (id,dimension_id,uom,abbreviation,conversion_factor) VALUES (3,2,'miles per hour','mph','1');
INSERT INTO `unit_of_measure` (id,dimension_id,uom,abbreviation,conversion_factor) VALUES (4,2,'kilometers per hour','kph','0.621371');
INSERT INTO `unit_of_measure` (id,dimension_id,uom,abbreviation,conversion_factor) VALUES (5,1,'yard','yd','0.000568182');

INSERT INTO `user` (id,username,person_id,location_id) VALUES (1,'digicow',1,NULL);
INSERT INTO `user` (id,username,person_id,location_id) VALUES (2,'rachel',2,NULL);
INSERT INTO `user` (id,username,person_id,location_id) VALUES (3,'eventyrrell',3,NULL);

INSERT INTO `person` (id,first_name,last_name) VALUES (1,'Mark','Tyrrell');
INSERT INTO `person` (id,first_name,last_name) VALUES (2,'Rachel','Tyrrell');
INSERT INTO `person` (id,first_name,last_name) VALUES (3,'Even','Tyrrell');

SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;

COMMIT;

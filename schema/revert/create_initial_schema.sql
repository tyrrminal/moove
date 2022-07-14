-- Revert moove:create_initial_schema from mysql

BEGIN;

SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

DROP TABLE `activity`;
DROP TABLE `activity_point`;
DROP TABLE `activity_reference`;
DROP TABLE `activity_type`;
DROP TABLE `address`;
DROP TABLE `dimension`;
DROP TABLE `distance`;
DROP TABLE `division`;
DROP TABLE `donation`;
DROP TABLE `event`;
DROP TABLE `event_group`;
DROP TABLE `event_group_series`;
DROP TABLE `event_reference`;
DROP TABLE `event_reference_type`;
DROP TABLE `event_registration`;
DROP TABLE `event_result`;
DROP TABLE `event_result_group`;
DROP TABLE `event_sequence`;
DROP TABLE `event_series`;
DROP TABLE `event_type`;
DROP TABLE `gender`;
DROP TABLE `goal`;
DROP TABLE `goal_comparator`;
DROP TABLE `goal_span`;
DROP TABLE `location`;
DROP TABLE `participant`;
DROP TABLE `person`;
DROP TABLE `result`;
DROP TABLE `unit_of_measure`;
DROP TABLE `user`;
DROP TABLE `user_goal`;
DROP TABLE `user_goal_fulfillment`;
DROP TABLE `user_goal_fulfillment_activity`;

SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;


COMMIT;

-- Deploy moove:add_missing_activity_types to mysql

BEGIN;

INSERT INTO `ActivityType` (`id`,`base_activity_type_id`,`activity_context_id`) VALUES
(14,1,9), -- Indoor Track Run
(15,9,5), -- Dumbell Anterior Deltoid Raise
(16,4,6)  -- Indoor Pool Swim
ON DUPLICATE KEY UPDATE 
	`base_activity_type_id`= VALUES(`base_activity_type_id`),
	`activity_context_id`  = VALUES(`activity_context_id`);

COMMIT;

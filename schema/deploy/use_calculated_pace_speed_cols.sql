-- Deploy moove:use_calculated_pace_speed_cols to mysql

BEGIN;

-- Delete orphaned rows that we wouldn't be able to determine activity type for
DELETE ap
FROM ActivityPoint ap 
WHERE ap.activity_result_id IN (
	SELECT ar.id
	FROM ActivityResult ar 
	WHERE NOT EXISTS (SELECT * FROM Activity a WHERE a.activity_result_id = ar.id)
	AND NOT EXISTS (SELECT * FROM EventParticipant ep WHERE ep.event_result_id = ar.id)
);

DELETE ar FROM ActivityResult ar
WHERE NOT EXISTS (SELECT * FROM Activity a WHERE a.activity_result_id = ar.id)
AND NOT EXISTS (SELECT * FROM EventParticipant ep WHERE ep.event_result_id = ar.id)
AND NOT EXISTS (SELECT * FROM ActivityPoint ap WHERE ar.id = ap.activity_result_id);

-- De-populate pace or speed columns where inapplicable
UPDATE ActivityResult ar
JOIN Activity a ON ar.id = a.activity_result_id 
JOIN ActivityType t ON a.activity_type_id = t.id
JOIN BaseActivityType bat ON t.base_activity_type_id = bat.id
SET ar.pace = NULL
WHERE bat.has_pace = 'N';

UPDATE ActivityResult ar
JOIN Activity a ON ar.id = a.activity_result_id 
JOIN ActivityType t ON a.activity_type_id = t.id
JOIN BaseActivityType bat ON t.base_activity_type_id = bat.id
SET ar.speed = NULL
WHERE bat.has_speed = 'N';

UPDATE ActivityResult ar
JOIN EventParticipant ep ON ep.event_result_id = ar.id
JOIN EventRegistration er ON ep.event_registration_id = er.id
JOIN EventActivity ea ON er.event_activity_id = ea.id
JOIN EventType et ON ea.event_type_id = et.id
JOIN ActivityType t ON et.activity_type_id = t.id
JOIN BaseActivityType bat ON t.base_activity_type_id = bat.id
SET ar.pace = NULL
WHERE bat.has_pace = 'N';

UPDATE ActivityResult ar
JOIN EventParticipant ep ON ep.event_result_id = ar.id
JOIN EventRegistration er ON ep.event_registration_id = er.id
JOIN EventActivity ea ON er.event_activity_id = ea.id
JOIN EventType et ON ea.event_type_id = et.id
JOIN ActivityType t ON et.activity_type_id = t.id
JOIN BaseActivityType bat ON t.base_activity_type_id = bat.id
SET ar.speed = NULL
WHERE bat.has_speed = 'N';

-- Persistently calculate speed from pace and vice versa
ALTER TABLE `ActivityResult` ADD COLUMN `speed_to_pace` TIME AS (SEC_TO_TIME(ROUND(60 * 60 * 1/`speed`))) PERSISTENT;
ALTER TABLE `ActivityResult` ADD COLUMN `pace_to_speed` DECIMAL(7,3) AS (1/(TIME_TO_SEC(IF(`pace`=0,NULL,`pace`))/(60 * 60))) PERSISTENT;

COMMIT;

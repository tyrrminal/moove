-- Revert moove:make_activity_user_required from mysql

BEGIN;

ALTER TABLE stats_cardio.activity MODIFY COLUMN user_id int(11) NULL;

COMMIT;

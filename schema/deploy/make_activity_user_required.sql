-- Deploy moove:make_activity_user_required to mysql

BEGIN;

ALTER TABLE stats_cardio.activity MODIFY COLUMN user_id int(11) NOT NULL;

COMMIT;

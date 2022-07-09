-- Revert moove:add_user_nominal_activity from mysql

BEGIN;

DROP TABLE `UserNominalActivityRange`;
DROP TABLE `UserNominalActivity`;

COMMIT;

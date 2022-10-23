-- Revert moove:add_runsignup_external_data_source from mysql

BEGIN;

DELETE FROM `ExternalDataSource` WHERE `name` = 'RunSignup';

COMMIT;

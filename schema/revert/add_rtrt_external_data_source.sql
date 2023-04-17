-- Revert moove:add_rtrt_external_data_source from mysql

BEGIN;

DELETE FROM `ExternalDataSource` WHERE `name` = 'Real-Time Race Tracking';

COMMIT;

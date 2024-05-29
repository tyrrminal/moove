-- Revert moove:add_webscorer_to_EDS from mysql

BEGIN;

DELETE FROM `ExternalDataSource` WHERE `name` = 'Webscorer';

COMMIT;

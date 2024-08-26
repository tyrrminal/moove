-- Revert moove:add_pcs_external_data_source from mysql

BEGIN;

DELETE FROM `ExternalDataSource` WHERE `name` = 'PretzelCitySports';

COMMIT;

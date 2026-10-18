-- Revert moove:add_mercurytiming_edc from mysql

BEGIN;

DELETE FROM `ExternalDataSource` WHERE `name` = 'MercuryTiming';

COMMIT;

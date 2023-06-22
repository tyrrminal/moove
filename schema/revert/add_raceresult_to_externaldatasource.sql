-- Revert moove:add_raceresult_to_externaldatasource from mysql

BEGIN;

DELETE FROM `ExternalDataSource` WHERE `name` = 'RaceResult';

COMMIT;

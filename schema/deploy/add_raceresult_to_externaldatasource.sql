-- Deploy moove:add_raceresult_to_externaldatasource to mysql

BEGIN;

INSERT INTO `ExternalDataSource` (`name`,`import_class`,`base_url`) VALUES ('RaceResult','Moove::Import::Event::RaceResult','https://raceresult.com');

COMMIT;

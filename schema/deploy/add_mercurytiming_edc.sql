-- Deploy moove:add_mercurytiming_edc to mysql

BEGIN;

INSERT INTO `ExternalDataSource` (`name`,`import_class`,`base_url`) VALUES ('MercuryTiming','Moove::Import::Event::MercuryTiming','https://live.rr.mercurytiming.com');

COMMIT;

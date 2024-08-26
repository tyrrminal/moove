-- Deploy moove:add_pcs_external_data_source to mysql

BEGIN;

INSERT INTO `ExternalDataSource` (`name`,`import_class`,`base_url`) VALUES ('PretzelCitySports','Moove::Import::Event::PretzelCitySports','https://www.pretzelcitysports.com/');

COMMIT;

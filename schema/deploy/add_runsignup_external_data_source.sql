-- Deploy moove:add_runsignup_external_data_source to mysql

BEGIN;

INSERT INTO `ExternalDataSource` (`name`,`import_class`,`base_url`) VALUES ('RunSignup','Moove::Import::Event::RunSignup','https://runsignup.com');

COMMIT;

-- Deploy moove:add_webscorer_to_EDS to mysql

BEGIN;

INSERT INTO `ExternalDataSource` (`name`,`import_class`,`base_url`) VALUES ('Webscorer','Moove::Import::Event::Webscorer','https://www.webscorer.com');

COMMIT;

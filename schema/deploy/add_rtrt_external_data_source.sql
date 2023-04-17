-- Deploy moove:add_rtrt_external_data_source to mysql

BEGIN;

INSERT INTO `ExternalDataSource` (`name`,`import_class`,`base_url`) VALUES ('Real-Time Race Tracking','Moove::Import::Event::RealTimeRaceTracking','https://rtrt.me');

COMMIT;

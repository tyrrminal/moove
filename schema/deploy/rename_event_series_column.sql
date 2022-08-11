-- Deploy moove:rename_event_series_column to mysql

BEGIN;

ALTER TABLE `EventSeriesEvent` RENAME COLUMN `event_group_id` TO `event_series_id`;

COMMIT;

-- Revert moove:rename_event_series_column from mysql

BEGIN;

ALTER TABLE `EventSeriesEvent` RENAME COLUMN `event_series_id` TO `event_group_id`;

COMMIT;

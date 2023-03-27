-- Revert moove:add_virtual_event_types from mysql

BEGIN;

ALTER TABLE `EventType` DROP COLUMN `is_virtual`;

COMMIT;

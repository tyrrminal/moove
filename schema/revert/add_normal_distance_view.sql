-- Revert moove:add_normal_distance_view from mysql

BEGIN;

DROP VIEW `DistanceNormalized`;

COMMIT;

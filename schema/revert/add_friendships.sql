-- Revert moove:add_friendships from mysql

BEGIN;

DROP TABLE `Friendship`;

COMMIT;

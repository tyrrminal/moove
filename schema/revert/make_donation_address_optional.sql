-- Revert moove:make_donation_address_optional from mysql

BEGIN;

ALTER TABLE `donation` MODIFY COLUMN `address_id` int(11) NOT NULL;

COMMIT;

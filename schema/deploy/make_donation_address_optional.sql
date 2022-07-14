-- Deploy moove:make_donation_address_optional to mysql

BEGIN;

ALTER TABLE `donation` MODIFY COLUMN `address_id` int(11) NULL;

COMMIT;

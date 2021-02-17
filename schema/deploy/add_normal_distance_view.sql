-- Deploy moove:add_normal_distance_view to mysql

BEGIN;

CREATE OR REPLACE VIEW `DistanceNormalized` AS
SELECT 
	d.`id`, 
	CASE WHEN uom.`inverted` = 'Y' THEN 1/(d.`value` * uom.`normalization_factor`)
	ELSE d.`value` * uom.`normalization_factor` 
	END AS `value`,
	COALESCE(uom.`normal_unit_id`,d.`unit_of_measure_id`) AS 'unit_of_measure_id'
FROM `Distance` d
JOIN `UnitOfMeasure` uom
	ON d.`unit_of_measure_id` = uom.`id`
ORDER BY d.id;

COMMIT;

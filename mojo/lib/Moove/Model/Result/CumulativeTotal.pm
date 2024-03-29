package Moove::Model::Result::CumulativeTotal;
use v5.38;

use base 'DBIx::Class::Core';

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('cumulative_total');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(<<'SQL');
SELECT a.user_id,a.activity_type_id,NULL AS 'year',SUM(d.value*u.conversion_factor) AS 'distance',prime.id AS 'uom'
FROM activity a
JOIN distance d
	ON a.distance_id=d.id
JOIN unit_of_measure u
	ON d.uom=u.id
JOIN unit_of_measure prime
  ON prime.conversion_factor=1
JOIN dimension di
  ON prime.dimension_id=di.id
  AND di.description = 'distance'
WHERE a.user_id IS NOT NULL
AND a.whole_activity_id IS NULL
GROUP BY a.user_id,a.activity_type_id

UNION

SELECT a.user_id,a.activity_type_id,YEAR(a.start_time) as 'year',SUM(d.value*u.conversion_factor) AS 'distance',prime.id AS 'uom'
FROM activity a
JOIN distance d
	ON a.distance_id=d.id
JOIN unit_of_measure u
	ON d.uom=u.id
JOIN unit_of_measure prime
  ON prime.conversion_factor=1
JOIN dimension di
  ON prime.dimension_id=di.id
  AND di.description = 'distance'
WHERE a.user_id IS NOT NULL
AND a.whole_activity_id IS NULL
GROUP BY a.user_id,a.activity_type_id,YEAR(a.start_time)
SQL

__PACKAGE__->add_columns(
  'user_id' => {
    data_type => 'integer',
  },
  'activity_type_id' => {
    data_type => 'integer'
  },
  'year' => {
    data_type => 'integer'
  },
  'distance' => {
    data_type => 'decimal'
  },
  'uom' => {
    data_type => 'integer'
  }
);

__PACKAGE__->belongs_to(
  "user",
  "Moove::Model::Result::User",
  {id => "user_id"},
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

__PACKAGE__->belongs_to(
  "activity_type",
  "Moove::Model::Result::ActivityType",
  {id            => "activity_type_id"},
  {is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION"},
);

__PACKAGE__->belongs_to(
  "uom",
  "Moove::Model::Result::UnitOfMeasure",
  {id            => "uom"},
  {is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION"},
);

1;

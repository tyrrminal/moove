package CardioTracker::Model::ResultSet::UnitOfMeasure;

use base qw(DBIx::Class::ResultSet);

use DCS::Constants qw(:existence);

sub normalization_unit {
  shift->search({conversion_factor => 1})->first;
}

1;

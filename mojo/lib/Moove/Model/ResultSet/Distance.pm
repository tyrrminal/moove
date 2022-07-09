package Moove::Model::ResultSet::Distance;
use v5.36;

use base qw(DBIx::Class::ResultSet);

sub find_or_create_in_units ($self, $d, $unit) {
  my $normal_unit = $unit->normal_unit // $unit;

  foreach (map {[$d / $_->normalization_factor, $_]}
    $self->result_source->schema->resultset('UnitOfMeasure')
    ->search({-or => [{id => $normal_unit->id}, {normal_unit_id => $normal_unit->id}]}))
  {
    my ($v, $u) = @$_;
    my $distance = $self->search(
      {
        value              => int($v * 100) / 100,
        unit_of_measure_id => $u->id,
      }
    )->first;
    return $distance if (defined($distance));

    return $self->create({value => $d, unit_of_measure => $unit});
  }

}

1;

package Moove::Model::ResultSet::Distance;
use base qw(DBIx::Class::ResultSet);

use experimental qw(signatures postderef);

sub find_or_create_in_units ($self, $d, $unit) {
  my $normal_unit = $unit->normal_unit // $unit;

  foreach (map {[$d / $_->normalization_factor, $_]}
    $self->result_source->schema->resultset('UnitOfMeasure')
    ->search({-or => [{id => $normal_unit->id}, {normal_unit_id => $normal_unit->id}]}))
  {
    my ($v, $u) = @$_;
    my $d = $self->search(
      {
        value              => int($v * 100) / 100,
        unit_of_measure_id => $u->id,
      }
    )->first;
    return $d if (defined($d));

    return $self->create({value => $d, unit_of_measure => $unit});
  }

}

1;

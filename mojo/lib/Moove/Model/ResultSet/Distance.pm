package Moove::Model::ResultSet::Distance;
use v5.36;

use base qw(DBIx::Class::ResultSet);

use Moove::Util::Unit::Conversion qw(unit_conversion);

sub find_or_create_in_units ($self, $d, $unit) {
  my $rs = $self->search({
    value              => $d,
    unit_of_measure_id => $unit->id
  });
  if(my $d = $rs->first) {return $d}
  
  if ($unit->normal_unit) {
    $rs = $self->search({
      value              => int(unit_conversion(value => $d, from => $unit) * 100) / 100,
      unit_of_measure_id => $unit->normal_unit->id
    });
    if(my $d = $rs->first) {return $d}
  }

  return $self->create({value => $d, unit_of_measure => $unit});
}

1;

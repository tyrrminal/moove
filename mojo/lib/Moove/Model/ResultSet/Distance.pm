package Moove::Model::ResultSet::Distance;
use v5.36;

use base qw(DBIx::Class::ResultSet);

use Moove::Util::Unit::Conversion qw(unit_conversion);

sub find_or_create_in_units ($self, $d, $unit) {
  my @search = (
    {
      value              => $d,
      unit_of_measure_id => $unit->id
    }
  );
  if ($unit->normal_unit) {
    push(
      @search, {
        value              => int(unit_conversion(value => $d, from => $unit) * 100) / 100,
        unit_of_measure_id => $unit->normal_unit->id
      }
    );
  }

  my $rs = $self->search({-or => [@search]});
  return $rs->first if ($rs->count > 0);
  return $self->create({value => $d, unit_of_measure => $unit});
}

1;

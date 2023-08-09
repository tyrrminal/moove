package Moove::Model::ResultSet::Distance;
use v5.36;
use builtin qw(true false);

use base qw(DBIx::Class::ResultSet);

use List::Util qw(uniq sum);
use Moove::Util::Unit::Conversion qw(unit_conversion);

use experimental qw(builtin);

sub new_normal($self, $value) {
  my $unit = $self->result_source->schema->resultset('UnitOfMeasure')->search({
      normal_unit_id          => undef, 
      'unit_of_measure_type.description' => 'Distance'
    }, {
      join => 'unit_of_measure_type'
    })->first;
  return $self->new({
    value => $value,
    unit_of_measure_id => $unit->id,
  })
}

sub find_or_create_in_units ($self, $d, $unit, $create = true) {
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

  if($create) {
    return $self->create({value => $d, unit_of_measure => $unit});
  } else {
    return $self->new({value => $d, unit_of_measure => $unit});
  }
}

sub distance_sum($self, @distances) {
  return unless(@distances);
  my $do_normalize = uniq(map {$_->unit_of_measure->id} @distances) > 1;
  my ($v,$u);
  if($do_normalize) {
    $v = sum(map { $_->normalized_value } @distances);
    $u = $distances[0]->normalized_unit;
  } else {
    $v = sum(map { $_->value } @distances);
    $u = $distances[0]->unit_of_measure;
  }
  return $self->result_source->schema->resultset('Distance')->find_or_create_in_units($v, $u, false);
}

1;

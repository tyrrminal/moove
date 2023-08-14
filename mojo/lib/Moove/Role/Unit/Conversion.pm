package Moove::Role::Unit::Conversion;
use v5.38;

use Role::Tiny;

use Moove::Util::Unit::Conversion qw(unit_conversion time_to_minutes minutes_to_time);

use DCS::Constants qw(:symbols);

sub normalized_pace ($self, $uv) {
  my $from = $self->model('UnitOfMeasure')->find($uv->{unit_of_measure_id});
  my $to   = $self->model('UnitOfMeasure')->per_mile;
  return $uv->{value} if ($from->id == $to->id);
  return minutes_to_time(
    unit_conversion(
      value => time_to_minutes($uv->{value}),
      from  => $from,
      to    => $to
    )
  );
}

sub normalized_speed ($self, $uv) {
  unit_conversion(value => $uv->{value}, from => $self->model('UnitOfMeasure')->find($uv->{unit_of_measure_id}));
}

1;

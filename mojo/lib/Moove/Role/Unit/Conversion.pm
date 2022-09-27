package Moove::Role::Unit::Conversion;
use v5.36;

use Role::Tiny;

use DateTime;
use DateTime::Format::Duration;
use Scalar::Util qw(looks_like_number);
use Readonly;
use Moove::Util::Unit::Conversion qw(unit_conversion);

use DCS::Constants qw(:symbols);

Readonly::Scalar my $SEC_PER_MIN  => 60;
Readonly::Scalar my $MIN_PER_HOUR => 60;

sub time_to_minutes ($self, $duration) {
  if (!ref($duration)) {
    my ($h, $m, $s) = split($COLON, $duration);
    $duration = DateTime::Duration->new(hours => $h, minutes => $m, seconds => $s);
  }
  my $minutes;
  $minutes += $duration->hours * $MIN_PER_HOUR;
  $minutes += $duration->minutes;
  $minutes += $duration->seconds / $SEC_PER_MIN;
  return $minutes;
}

sub minutes_to_time ($self, $num) {
  return DateTime->today()->add(minutes => int($num * $SEC_PER_MIN + 0.5) / $SEC_PER_MIN)->strftime('%T');
}

sub normalized_pace ($self, $uv) {
  my $from = $self->model('UnitOfMeasure')->find($uv->{unit_of_measure_id});
  my $to   = $self->model('UnitOfMeasure')->find({abbreviation => '/mi'});
  return $uv->{value} if ($from->id == $to->id);
  return $self->minutes_to_time(
    unit_conversion(
      value => $self->time_to_minutes($uv->{value}),
      from  => $from,
      to    => $to
    )
  );
}

sub normalized_speed ($self, $uv) {
  unit_conversion(value => $uv->{value}, from => $self->model('UnitOfMeasure')->find($uv->{unit_of_measure_id}));
}

1;

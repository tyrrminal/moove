package Moove::Role::Unit::Conversion;
use Role::Tiny;
use v5.32;
use strict;
use warnings;

use boolean;
use DateTime::Format::Duration;
use Scalar::Util qw(looks_like_number);

use DCS::Constants qw(:symbols);

use experimental qw(signatures postderef);

sub time_to_minutes ($self, $duration) {
  my $minutes;
  $minutes += $duration->hours * 60;
  $minutes += $duration->minutes;
  $minutes += $duration->seconds / 60;
  return $minutes;
}

sub minutes_to_time ($self, $num) {

}

###
#  Convert a value from one UnitOfMeasure to another
#  Params:
#    value: a number (required)
#    from:  a UnitOfMeasure (required)
#      to:  a UnitOfMeasure (optional; assumed to be from's normal unit if omitted)
###
sub unit_conversion ($self, %params) {
  my $uc = 'Moove::Model::Result::UnitOfMeasure';

  my $v = $params{value};
  return unless defined($v);
  return unless looks_like_number($v);

  my $from = $params{from};
  my $to   = $params{to};
  warn("From must be a Model UnitOfMeasure") and return if (!defined($from) || ref($from) ne $uc);
  warn("To must be a Model UnitOfMeasure") and return if (defined($to) && ref($to) ne $uc);

  $to = $from->normal_unit // $from unless (defined($to));
  return $v if ($from->id == $to->id);

  $v = 1 / $v if ($from->inverted);
  $v *= $from->normalization_factor;
  $v /= $to->normalization_factor;
  $v = 1 / $v if ($to->inverted);
  return $v;
}

1;

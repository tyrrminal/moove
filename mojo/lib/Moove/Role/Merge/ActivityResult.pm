package Moove::Role::Merge::ActivityResult;
use v5.38;

use Role::Tiny;

use DateTime::Duration;
use DateTime::Format::Duration;
use List::Util                    qw(sum min);
use Moove::Util::Unit::Conversion qw(unit_conversion minutes_to_time);

sub _avg_val ($key, @results) {
  return undef unless (grep {defined($_->{$key})} @results);
  my $to_sec = DateTime::Format::Duration->new(pattern => '%s', normalize => 1);
  my ($time, $total) = (DateTime::Duration->new(hours => 0, minutes => 0, seconds => 0), 0);
  foreach (@results) {
    if (defined($_->$key)) {
      $time  = $time->add($_->net_time);
      $total = $total + $_->$key * $to_sec->format_duration($_->net_time) / 60;
    }
  }
  return undef unless ($total);
  my $min = $to_sec->format_duration($time) / 60;
  return $total / $min;
}

sub merge_durations ($self, @results) {
  return $results[-1]->end_time - $results[0]->start_time;
}

sub merge_net_times ($self, @results) {
  return undef unless (grep {defined($_->net_time)} @results);
  my $nt = DateTime::Duration->new(hours => 0, minutes => 0, seconds => 0);
  foreach my $ar (@results) {
    $nt->add($ar->net_time // $ar->duration);
  }
  return $nt;
}

sub merge_distances ($self, @results) {
  my %units = map {$_->distance->unit_of_measure_id => $_->distance->unit_of_measure} @results;
  my $u     = (values(%units))[0];
  $u = $u->normalized_unit if ((keys(%units) > 1));
  my $value =
    sum(map {unit_conversion(value => $_->distance->value, from => $_->distance->unit_of_measure, to => $u)} @results);
  return {
    unit_of_measure => $u,
    value           => $value
  };
}

sub merge_paces ($self, @results) {
  my $pace_unit = $self->model('UnitOfMeasure')->find({abbreviation => '/mi'});
  return minutes_to_time(unit_conversion($self->merge_speeds(@results), from => $pace_unit->normal_unit, to => $pace_unit));
}

sub merge_speeds ($self, @results) {
  my $to_sec = DateTime::Format::Duration->new(pattern => '%s', normalize => 1);

  my $time     = $self->merge_net_times(@results) // $self->merge_durations(@results);
  my $distance = $self->merge_distances(@results);
  my $nv       = unit_conversion(value => $distance->{value}, from => $distance->{unit_of_measure});
  return $nv / ($to_sec->format_duration($time) / (60 * 60));
}

sub merge_repetitions ($self, @results) {
  return undef;
}

sub merge_map_visibility_types ($self, @results) {
  return min(map {$_->map_visibility_type_id // 3} @results);
}

sub merge_weights ($self, @results) {
  return _avg_val('weight', @results);
}

sub merge_temperatures ($self, @results) {
  return _avg_val('temperature', @results);
}

sub merge_heart_rates ($self, @results) {
  return _avg_val('heart_rate', @results);
}

1;

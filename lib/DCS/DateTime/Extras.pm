package DCS::DateTime::Extras;
use Mojo::Base -strict, -signatures;

#no warnings qw(once);

sub DateTime::yearfrac ($self, $d) {
  my ($g, $l) = ($self > $d) ? ($self, $d) : ($d, $self);

  my $whole_diff = $g->year - $l->year;

  $l = DateTime->new(year => $g->year, month => $l->month, day => $l->day);
  if ($l > $g) {
    $whole_diff--;
    $l = DateTime->new(year => $g->year - 1, month => $l->month, day => $l->day);
  }
  my $partial_diff = $g->delta_days($l)->in_units('days') / $l->year_length;

  return $whole_diff + $partial_diff;
}

sub DateTime::start_of_year($self) {
  return DateTime->new(
    time_zone => $self->time_zone,
    day       => 1,
    month     => 1,
    year      => $self->year
  );
}

sub DateTime::start_of_month($self) {
  return DateTime->new(
    time_zone => $self->time_zone,
    day       => 1,
    month     => $self->month,
    year      => $self->year
  );
}

sub DateTime::start_of_week($self) {
  my $dt = $self->clone();
  $dt->subtract(days => $dt->day_of_week % 7);
  return $dt;
}

sub DateTime::start_of_week_in_year($self) {
  my $dt = $self->start_of_week;
  if ($dt->year == $self->year) {
    return $dt;
  } else {
    return $self->start_of_year;
  }
}

sub DateTime::Duration::to_hash ($self, @_) {
  my $r;
  my $act = 0;
  foreach (qw(years months weeks days hours minutes seconds)) {
    my $v = $self->$_;
    $act |= $v > 0;
    $r->{$_} = $v if ($act);
  }
  return $r;
}

1;

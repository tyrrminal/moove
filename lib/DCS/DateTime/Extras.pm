package DCS::DateTime::Extras;

*DateTime::yearfrac = sub {
  my $self=shift;
  my ($d) = @_;

  my ($g,$l) = ($self > $d) ? ($self,$d) : ($d,$self);

  my $whole_diff = $g->year - $l->year;

  $l = DateTime->new(year => $g->year, month => $l->month, day => $l->day);
  if($l > $g) {
    $whole_diff--;
    $l = DateTime->new(year => $g->year-1, month => $l->month, day => $l->day);
  }
  my $partial_diff = $g->delta_days($l)->in_units('days')/$l->year_length;

  return $whole_diff + $partial_diff;
};

*DateTime::start_of_year = sub {
  my $self = shift;

  return DateTime->new(
    time_zone => $self->time_zone,
    day => 1,
    month => 1,
    year => $self->year
  );
};

*DateTime::start_of_month = sub {
  my $self=shift;

  return DateTime->new(
    time_zone => $self->time_zone,
    day => 1,
    month => $self->month,
    year => $self->year
  )
};

*DateTime::start_of_week = sub {
  my $self=shift;

  my $dt = $self->clone();
  $dt->subtract(days => $dt->day_of_week%7);
  return $dt;
};

*DateTime::start_of_week_in_year = sub {
  my $self=shift;

  my $dt = $self->start_of_week;
  if($dt->year == $self->year) {
    return $dt;
  } else {
    return $self->start_of_year;
  }
};

1;

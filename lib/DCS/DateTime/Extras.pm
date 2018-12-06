package DCS::DateTime::Extras;

*DateTime::yearfrac = sub {
  my $self=shift;
  my ($d) = @_;

  my ($g,$l) = ($self > $d) ? ($self,$d) : ($d,$self);

  my $whole_diff = $g->year - $l->year;

  $l = DateTime->new(year => $g->year, month => $l->month, day => $l->day);
  if($l > $g) {
    $l = DateTime->new(year => $g->year-1, month => $l->month, day => $l->day);
  }
  my $partial_diff = $g->delta_days($l)->in_units('days')/$l->year_length;

  return $whole_diff + $partial_diff;
};

1;

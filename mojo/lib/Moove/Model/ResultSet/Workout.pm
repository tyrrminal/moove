package Moove::Model::ResultSet::Workout;
use v5.38;

use base qw(DBIx::Class::ResultSet);

use builtin      qw(true false);
use experimental qw(builtin);

sub after_date ($self, $date, $inclusive = true) {
  my $d  = ref($date) ? DateTime::Format::MySQL->format_date($date) : $date;
  my $op = $inclusive ? '>='                                        : '>';
  return $self->search(
    {
      date => {$op => $d}
    }
  );
}

sub before_date ($self, $date, $inclusive = false) {
  my $d  = ref($date) ? DateTime::Format::MySQL->format_date($date) : $date;
  my $op = $inclusive ? '<='                                        : '<';
  return $self->search(
    {
      date => {$op => $d}
    }
  );
}

1;

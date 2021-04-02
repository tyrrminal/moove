package Moove::Model::ResultSet::Workout;
use strict;
use warnings;

use base qw(DBIx::Class::ResultSet);

use experimental qw(signatures postderef);

sub after_date ($self, $date) {
  my $d = ref($date) ? DateTime::Format::MySQL->format_date($date) : $date;
  return $self->search(
    {
      date => {'>=' => $d}
    }
  );
}

sub before_date ($self, $date) {
  my $d = ref($date) ? DateTime::Format::MySQL->format_date($date) : $date;
  return $self->search(
    {
      date => {'<=' => $d}
    }
  );
}

1;

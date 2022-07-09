package Moove::Model::ResultSet::Workout;
use v5.36;

use base qw(DBIx::Class::ResultSet);

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

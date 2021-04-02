package Moove::Model::ResultSet::Person;
use strict;
use warnings;

use base qw(DBIx::Class::ResultSet);

use experimental qw(signatures postderef);

sub find_or_create_donor($self, $first_name, $last_name) {
  my ($person) = $self->search(
    {
      first_name => $first_name,
      last_name  => $last_name
    }, {
      join => 'donations'
    }
  )->first;
  $person = $self->create(
    {
      first_name => $first_name,
      last_name  => $last_name
    }
    )
    unless (defined($person));

  return $person;
}

1;

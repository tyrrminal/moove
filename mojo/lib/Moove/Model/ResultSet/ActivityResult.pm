package Moove::Model::ResultSet::ActivityResult;
use v5.36;

use base qw(DBIx::Class::ResultSet);

sub with_distance ($self) {
  return $self->search({distance_id => {'<>' => undef}});
}

1;

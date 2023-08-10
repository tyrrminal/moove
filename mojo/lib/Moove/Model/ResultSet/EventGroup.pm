package Moove::Model::ResultSet::EventGroup;
use v5.38;

use base qw(DBIx::Class::ResultSet);

sub filter_name($self, $name) {
  return $self->search({
    name => {-like => "%$name%"}
  })
}

sub type_series($self) {
  return $self->search({ year => {'<>' => undef}})
}

sub type_parent($self) {
  return $self->search({ year => {'=' => undef}})
}

1;

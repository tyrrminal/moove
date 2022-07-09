package Moove::Model::ResultSet::EventPlacementPartition;
use v5.36;

use base qw(DBIx::Class::ResultSet);

sub for_event ($self, $event) {
  return $self->search(
    {
      event_id => $event->id
    }
  );
}

sub missing_count ($self) {
  return $self->search({count => {'=', undef}});
}

1;

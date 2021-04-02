package Moove::Model::ResultSet::EventPlacementPartition;
use strict;
use warnings;

use base qw(DBIx::Class::ResultSet);

use DCS::Constants qw(:existence);

use experimental qw(signatures postderef);

sub for_event($self, $event) {
  return $self->search(
    {
      event_id => $event->id
    }
  );
}

sub missing_count($self) {
  return $self->search({count => {'=', $NULL}});
}

1;

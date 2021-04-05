package Moove::Controller::Role::ModelEncoding::EventPlacement;
use Role::Tiny;

use experimental qw(signatures postderef);

sub encode_model_eventplacement ($self, $entity) {
  my $r = {
    place       => $entity->place,
    of          => $entity->event_placement_partition->participants->count,
    description => $entity->event_placement_partition->description,
  };
  if (my $pt = $entity->event_placement_partition->partition_type) {
    $r->{partition_type} = $pt;
  }
  return $r;
}

1;

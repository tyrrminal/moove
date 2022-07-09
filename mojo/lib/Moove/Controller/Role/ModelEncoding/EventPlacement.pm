package Moove::Controller::Role::ModelEncoding::EventPlacement;
use v5.36;

use Role::Tiny;

sub encode_model_eventplacement ($self, $entity) {
  my $r = {
    place       => $entity->place,
    of          => $entity->event_placement_partition->participants->count,
    description => $entity->event_placement_partition->description,
  };
  if (my $pt = $entity->event_placement_partition->partition_type) {
    $r->{partitionType} = $pt;
  }
  return $r;
}

1;

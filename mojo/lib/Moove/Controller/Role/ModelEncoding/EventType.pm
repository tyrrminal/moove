package Moove::Controller::Role::ModelEncoding::EventType;
use Role::Tiny;

use experimental qw(signatures postderef);

sub encode_model_eventtype ($self, $entity) {
  return {
    id           => $entity->id,
    description  => $entity->description,
    activityType => $self->encode_model($entity->activity_type),
    };
}

1;

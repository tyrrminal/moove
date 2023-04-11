package Moove::Controller::Role::ModelEncoding::EventType;
use v5.36;

use Role::Tiny;

sub encode_model_eventtype ($self, $entity) {
  return {
    id           => $entity->id,
    description  => $entity->description,
    activityType => $self->encode_model($entity->activity_type),
    virtual      => $entity->is_virtual
    };
}

1;

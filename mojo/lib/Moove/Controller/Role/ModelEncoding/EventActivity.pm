package Moove::Controller::Role::ModelEncoding::EventActivity;
use v5.36;

use Role::Tiny;

use DateTime;

sub encode_model_eventtype ($self, $entity) {
  return {id => $entity->id};
}

sub encode_model_eventactivity ($self, $entity) {
  return {
    id                 => $entity->id,
    name               => $entity->name,
    entrants           => $entity->entrants,
    scheduledStart     => $self->encode_datetime($entity->scheduled_start),
    eventType          => $self->encode_model($entity->event_type),
    distance           => $self->encode_model($entity->distance),
    externalIdentifier => $entity->external_identifier,
    results            => {
      importable => defined($entity->event->external_identifier) && $entity->scheduled_start < DateTime->now(),
    }
  };
}

1;

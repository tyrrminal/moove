package Moove::Controller::Role::ModelEncoding::Registration::EventActivity;
use Role::Tiny;

use experimental qw(signatures postderef);

sub encode_model_eventactivity ($self, $entity) {
  return {
    id             => $entity->id,
    name           => $entity->name,
    event          => $self->encode_model($entity->event),
    entrants       => $entity->entrants,
    scheduledStart => $self->encode_datetime($entity->scheduled_start),
    eventType      => $self->encode_model($entity->event_type),
    distance       => $self->encode_model($entity->distance),
    resultsURL     => $entity->url,
  };
}

1;

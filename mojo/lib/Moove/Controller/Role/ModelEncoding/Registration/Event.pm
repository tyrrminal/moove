package Moove::Controller::Role::ModelEncoding::Registration::Event;
use v5.38;

use Role::Tiny;

sub encode_model_event ($self, $event) {
  return {
    id      => $event->id,
    name    => $event->name,
    year    => $event->year,
    address => $self->encode_model($event->address),
    defined($event->event_group) ? (eventGroup => $self->encode_model($event->event_group)) : (),
    eventSeries => $self->encode_model([$event->event_series]),
  };
}

1;

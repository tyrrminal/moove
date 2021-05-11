package Moove::Controller::Role::ModelEncoding::Registration::Event;
use Role::Tiny;

use experimental qw(signatures);

sub encode_model_event ($self, $event) {
  return {
    id      => $event->id,
    name    => $event->name,
    year    => $event->year,
    url     => $event->url,
    address => $self->encode_model($event->address),
    defined($event->event_group) ? (eventGroup => $self->encode_model($event->event_group)) : (),
    eventSeries => $self->encode_model([$event->event_groups]),
  };
}

1;

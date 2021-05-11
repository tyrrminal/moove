package Moove::Controller::Role::ModelEncoding::Event;
use Role::Tiny;

use experimental qw(signatures);

sub encode_model_event ($self, $event) {
  return {
    id         => $event->id,
    name       => $event->name,
    url        => $event->url,
    year       => $event->year,
    address    => $self->encode_model($event->address),
    activities => $self->encode_model([$event->event_activities]),
    defined($event->event_group) ? (event_group => $self->encode_model($event->event_group)) : (),
    event_series => $self->encode_model([$event->event_groups]),
  };
}

1;

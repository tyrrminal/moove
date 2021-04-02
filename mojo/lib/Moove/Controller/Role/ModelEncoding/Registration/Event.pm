package Moove::Controller::Role::ModelEncoding::Registration::Event;
use Role::Tiny;

use experimental qw(signatures);

sub encode_model_event ($self, $event) {
  return {
    id => $event->id,
    name => $event->name,
    year => $event->year,
    address => $self->encode_model($event->address),
    defined($event->event_group) ? (event_group => $self->encode_model($event->event_group)) : (),
    event_series => $self->encode_model([$event->event_groups]),
  };
}

1;

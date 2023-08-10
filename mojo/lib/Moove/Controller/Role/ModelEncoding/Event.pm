package Moove::Controller::Role::ModelEncoding::Event;
use v5.38;

use Role::Tiny;

sub encode_model_event ($self, $event) {
  return {
    id         => $event->id,
    name       => $event->name,
    url        => $event->url,
    year       => $event->year,
    address    => $self->encode_model($event->address),
    activities => $self->encode_model([$event->event_activities]),
    defined($event->event_group) ? (eventGroup => $self->encode_model($event->event_group)) : (),
    eventSeries          => $self->encode_model([$event->event_series]),
    externalDataSourceID => $event->external_data_source_id,
    importParameters     => $event->import_params,
  };
}

1;

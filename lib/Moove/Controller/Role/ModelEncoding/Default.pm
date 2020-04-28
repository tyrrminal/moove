package Moove::Controller::Role::ModelEncoding::Default;
use Role::Tiny;

use experimental qw(signatures);

sub render_model_cumulativetotal ($self, $total) {
  return {
    type     => $self->render_model($total->activity_type),
    uom      => $self->render_model($total->uom),
    distance => $total->distance,
    year     => $total->year,
  };
}

sub render_model_event ($self, $event) {
  return {
    id             => $event->id,
    name           => $event->event_group->name,
    url            => $event->event_group->url,
    scheduledStart => $self->render_datetime($event->scheduled_start),
  };
}

sub render_model_person ($self, $person) {
  return {
    id        => $person->id,
    lastname  => $person->last_name,
    firstname => $person->first_name,
  };
}

sub render_model_unitofmeasure ($self, $uom) {
  return {
    id                  => $uom->id,
    unit                => $uom->uom,
    abbreviation        => $uom->abbreviation,
    normalizationFactor => $uom->conversion_factor,
  };
}

sub render_model_user ($self, $user) {
  return {
    id       => $user->id,
    username => $user->username,
    person   => $self->render_model($user->person),
  };
}


1;

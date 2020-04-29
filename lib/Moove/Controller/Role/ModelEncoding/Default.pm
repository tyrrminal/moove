package Moove::Controller::Role::ModelEncoding::Default;
use Role::Tiny;

use experimental qw(signatures);

sub render_model_cumulativetotal ($self, $total) {
  return {
    activityTypeID => $total->activity_type_id,
    unitID         => $total->uom->id,
    distance       => $total->distance,
    year           => $total->year,
  };
}

sub render_model_distance ($self, $distance) {
  return {
    id     => $distance->id,
    value  => $distance->value,
    unitID => $distance->uom->id,
  };
}

sub render_model_event ($self, $event) {
  return {
    id             => $event->id,
    name           => join(" - ", grep {defined} ($event->event_group->name, $event->name || undef)),
    entrants       => $event->entrants,
    url            => $event->event_group->url,
    scheduledStart => $self->render_datetime($event->scheduled_start),
    eventTypeID    => $event->event_type_id,
    distance       => $self->render_model($event->distance),
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
    label               => $uom->uom,
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

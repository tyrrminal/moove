package Moove::Controller::Donor;
use Mojo::Base 'DCS::Base::API::Model::Controller';

use Role::Tiny::With;
with 'DCS::Base::Role::Rest::Get';

use HTTP::Status qw(:constants);

use experimental qw(signatures postderef);

sub encode_model_person ($self, $entity) {
  return {
    person => {
      id        => $entity->id,
      firstname => $entity->firstname,
      lastname  => $entity->lastname,
    },
    donations => $self->encode_model([$entity->donations->for_events_for_user($self->current_user)->ordered->all])
  };
}

sub encode_model_donation ($self, $entity) {
  return {
    amount  => $entity->amount,
    date    => $self->encode_date($entity->date),
    address => $self->encode_model($entity->address),
    event   => $self->encode_model($entity->user_event_activity->event_registration->event_activity)
  };
}

sub encode_model_eventactivity ($self, $entity) {
  return {
    id                => $entity->id,
    eventActivityName => $entity->name,
    eventName         => $entity->event->name,
    eventYear         => $entity->event->year,
  };
}

sub model_name ($self) {
  return 'Person';
}

1;

package Moove::Controller::Role::ModelEncoding::Workout;
use v5.36;

use Role::Tiny;
with 'Moove::Controller::Role::ModelEncoding::Activity';

sub encode_model_workout ($self, $entity) {
  return {
    id         => $entity->id,
    date       => $self->encode_date($entity->date),
    name       => $entity->name,
    user       => $self->encode_model($entity->user),
    activities => $self->encode_model([$entity->activities->all]),
  };
}

sub encode_model_user ($self, $entity) {
  return {
    id       => $entity->id,
    username => $entity->username,
  };
}

1;

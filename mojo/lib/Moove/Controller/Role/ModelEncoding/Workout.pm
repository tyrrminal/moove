package Moove::Controller::Role::ModelEncoding::Workout;
use Role::Tiny;

use experimental qw(signatures postderef);

sub encode_model_workout ($self, $entity) {
  return {
    id   => $entity->id,
    date => $self->encode_date($entity->date),
    name => $entity->name,
    user => $self->encode_model($entity->user),
  };
}

sub encode_model_user ($self, $entity) {
  return {
    id       => $entity->id,
    username => $entity->username,
    };
}

1;

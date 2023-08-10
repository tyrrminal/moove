package Moove::Controller::Role::ModelEncoding::Donation;
use v5.38;

use Role::Tiny;

sub encode_model_donation ($self, $entity) {
  return {
    id      => $entity->id,
    amount  => $entity->amount,
    date    => $self->encode_date($entity->date),
    person  => $self->encode_model($entity->person),
    address => $self->encode_model($entity->address),
  };
}

1;

package Moove::Controller::Role::ModelEncoding::Activity;
use Role::Tiny;

with 'Moove::Controller::Role::ModelEncoding::ActivityType';

use experimental qw(signatures postderef);

sub encode_model_activity ($self, $entity) {
  return {
    id           => $entity->id,
    activityType => $self->encode_model($entity->activity_type),
    note         => $entity->note,
  };
}

1;

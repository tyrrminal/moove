package Moove::Controller::Role::ModelEncoding::ActivityType;
use Role::Tiny;

use experimental qw(signatures postderef);

sub encode_model_activitytype ($self, $entity) {
  return {
    id          => $entity->id,
    description => $entity->description,
  };
}

1;

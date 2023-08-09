package Moove::Controller::Role::ModelEncoding::Activity::UserEventActivity;
use v5.38;

use Role::Tiny;

sub encode_model_usereventactivity ($self, $entity) {
  return {
    id => $entity->id,
    name => $entity->name
  }
}

1;

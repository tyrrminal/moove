package Moove::Controller::Role::ModelEncoding::EventGroup;
use v5.38;

use Role::Tiny;

sub encode_model_eventgroup ($self, $entity) {
  return {
    id       => $entity->id,
    name     => $entity->name,
    isParent => $entity->is_parent,
    url      => $entity->url,
  };
}

1;

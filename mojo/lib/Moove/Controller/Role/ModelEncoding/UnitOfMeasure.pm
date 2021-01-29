package Moove::Controller::Role::ModelEncoding::UnitOfMeasure;
use Role::Tiny;

use experimental qw(signatures);

sub encode_model_unitofmeasure ($self, $entity) {
  return {
    id                  => $entity->id,
    name                => $entity->name,
    abbreviation        => $entity->abbreviation,
    normalizationFactor => $entity->normalization_factor,
    };
}

1;

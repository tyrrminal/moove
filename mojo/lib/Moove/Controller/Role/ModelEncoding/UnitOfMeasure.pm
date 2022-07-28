package Moove::Controller::Role::ModelEncoding::UnitOfMeasure;
use v5.36;

use Role::Tiny;

sub encode_model_unitofmeasure ($self, $entity) {
  return {
    id                  => $entity->id,
    name                => $entity->name,
    abbreviation        => $entity->abbreviation,
    normalizationFactor => $entity->normalization_factor,
    normalUnitID        => $entity->normal_unit_id,
    type                => $entity->unit_of_measure_type->description,
    inverted            => $entity->inverted
  };
}

1;

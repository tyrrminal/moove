package Moove::Controller::Role::ModelEncoding::Distance;
use v5.36;

use Role::Tiny;
with 'Moove::Controller::Role::ModelEncoding::UnitOfMeasure';

sub encode_model_distance ($self, $entity) {
  return {
    # id              => $entity->id,
    value           => $entity->value,
    unitOfMeasureID => $entity->unit_of_measure_id,
  };
}

1;

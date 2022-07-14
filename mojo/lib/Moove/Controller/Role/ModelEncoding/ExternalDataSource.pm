package Moove::Controller::Role::ModelEncoding::ExternalDataSource;
use v5.36;

use Role::Tiny;

use DCS::Constants qw(:semantics);

sub encode_model_externaldatasource ($self, $entity) {
  return {
    id   => $entity->id,
    name => $entity->name,
    type => (split($NAMESPACE_IDENTIFIER, $entity->import_class))[2],
    ($entity->base_url ? (baseURL => $entity->base_url) : ()),
  };
}

1;

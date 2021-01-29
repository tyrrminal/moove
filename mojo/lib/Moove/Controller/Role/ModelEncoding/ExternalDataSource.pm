package Moove::Controller::Role::ModelEncoding::ExternalDataSource;
use Role::Tiny;

use DCS::Constants qw(:semantics);

use experimental qw(signatures);

sub encode_model_externaldatasource ($self, $entity) {
  return {
    id   => $entity->id,
    name => $entity->name,
    type => (split($NAMESPACE_IDENTIFIER, $entity->import_class))[2],
    ($entity->base_url ? (baseUrl => $entity->base_url) : ()),
  };
}

1;

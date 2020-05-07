package Moove::Controller::Role::ModelDecoding::Default;
use Role::Tiny;

use experimental qw(signatures);

sub decode_model ($self, $model) {
  return $model;
}

1;

package Moove::Controller::Role::ModelDecoding::Default;
use v5.36;

use Role::Tiny;

sub decode_model ($self, $model) {
  return $model;
}

1;

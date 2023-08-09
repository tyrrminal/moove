package Moove::Controller::Role::ModelEncoding::AuthUser;
use v5.38;

use Role::Tiny;

sub encode_model_person ($self, $person) {
  return {
    ($person->id ? (id => $person->id) : ()),
    lastname  => $person->lastname,
    firstname => $person->firstname,
  };
}

sub encode_model_user ($self, $user) {
  return {
    ($user->id ? (id => $user->id) : ()),
    username => $user->username,
    person   => $self->encode_model($user->person),
  };
}

1;

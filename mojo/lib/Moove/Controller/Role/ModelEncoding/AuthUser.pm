package Moove::Controller::Role::ModelEncoding::AuthUser;
use Role::Tiny;

use experimental qw(signatures);

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

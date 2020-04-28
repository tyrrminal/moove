package Moove::Controller::Role::ModelEncoding::AuthUser;
use Role::Tiny;

use experimental qw(signatures);

sub render_model_person ($self, $person) {
  return {
    ($person->id ? (id => $person->id) : ()),
    lastname  => $person->last_name,
    firstname => $person->first_name,
  };
}

sub render_model_user ($self, $user) {
  return {
    ($user->id ? (id => $user->id) : ()),
    username => $user->username,
    person   => $self->render_model($user->person),
  };
}

1;

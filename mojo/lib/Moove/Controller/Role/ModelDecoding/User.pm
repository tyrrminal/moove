package Moove::Controller::Role::ModelDecoding::User;
use v5.36;

use Role::Tiny;

sub decode_model_person ($self, $person) {
  $person->{first_name} = delete($person->{firstname});
  $person->{last_name}  = delete($person->{lastname});
  return $person;
}

sub decode_model_user ($self, $user) {
  $user->{person} = $self->decode_model_person(delete($user->{person}));
  return $user;
}

sub decode_model ($self, $model) {
  return $self->decode_model_user($model);
}

1;

package Moove::Controller::Admin::User;
use v5.38;

use Mojo::Base 'DCS::Base::API::Model::Controller';
use Role::Tiny::With;

with 'DCS::Base::Role::Rest::Create',
  'DCS::Base::Role::Rest::Delete',
  'DCS::Base::Role::Rest::Get',
  'DCS::Base::Role::Rest::List',
  'DCS::Base::Role::Rest::Update';
with 'Moove::Controller::Role::ModelEncoding::Default';
with 'Moove::Controller::Role::ModelDecoding::User';

sub decode_model ($self, $data) { }

sub resultset ($self, @args) {
  my $rs = $self->SUPER::resultset(@args);
  if (my $username = $self->validation->param('username')) {
    $rs = $rs->search({username => {-like => "%$username%"}});
  }
  return $rs;
}

sub perform_update ($self, $user, $data) {
  $user->person->update(delete($data->{person})) if (exists($data->{person}));
  $user->update($data);
}

sub perform_delete ($self, $user) {
  my $person = $user->person;
  $user->delete;
  $person->delete unless ($person->donations->count || $person->participants->count);
}

1;

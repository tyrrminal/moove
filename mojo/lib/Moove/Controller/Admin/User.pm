package Moove::Controller::Admin::User;
use Mojo::Base 'DCS::API::Base::ModelController';
use Role::Tiny::With;

with 'DCS::API::Role::Rest::Create',
  'DCS::API::Role::Rest::Delete',
  'DCS::API::Role::Rest::Get',
  'DCS::API::Role::Rest::List',
  'DCS::API::Role::Rest::Update';
with 'Moove::Controller::Role::ModelEncoding::Default';
with 'Moove::Controller::Role::ModelDecoding::User';

use experimental qw(signatures);

sub resultset($self) {
  my $rs = $self->SUPER::resultset();
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

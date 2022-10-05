package Moove::Model::ResultSet::User;
use v5.36;

use base qw(DBIx::Class::ResultSet);

use DCS::Constants qw(:symbols);

use builtin      qw(false);
use experimental qw(builtin);

sub guest ($self) {
  return $self->new_result({id => 0, username => 'guest', person => {id => 0, firstname => 'guest', lastname => 'user'}});
}

sub is_friends_with ($self, $user) {
  # TODO: implement friends capabilities
  return false;
}

sub find_user ($self, $user_id) {
  my $search_field = ($user_id =~ /\D/) ? 'username' : 'id';
  return $self->search({$search_field => $user_id})->first;
}

1;

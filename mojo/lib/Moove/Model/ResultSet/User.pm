package Moove::Model::ResultSet::User;

use base qw(DBIx::Class::ResultSet);

sub guest {
  my $self = shift;
  return $self->new_result({id => 0, username => 'guest', person => {id => 0, first_name => 'guest', last_name => 'user'}});
}

sub find_user {
  my $self         = shift;
  my ($user_id)    = @_;
  my $search_field = ($user_id =~ /\D/) ? 'username' : 'id';

  return $self->search({$search_field => $user_id})->first;
}

1;

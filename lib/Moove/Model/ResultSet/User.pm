package Moove::Model::ResultSet::User;

use base qw(DBIx::Class::ResultSet);

sub anonymous {
  my $self = shift;
  return $self->new_result({id => 0, username => 'guest'});
}

sub find_user {
  my $self = shift;
  my ($user_id) = @_;
  my $search_field = ($user_id =~ /\D/) ? 'username' : 'id';

  return $self->search({$search_field => $user_id})->first;
}

1;

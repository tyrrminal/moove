package CardioTracker::Model::ResultSet::User;

use base qw(DBIx::Class::ResultSet);

sub anonymous {
  my $self=shift;
  return $self->new_result({id => 0, username => ''});
}

1;

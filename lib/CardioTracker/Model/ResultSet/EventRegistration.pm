package CardioTracker::Model::ResultSet::EventRegistration;

use base qw(DBIx::Class::ResultSet);

sub for_user {
  my $self=shift;
  my ($user) = shift;

  return $self->search({
    user_id => $user->id
  })
}

sub ordered {
  my $self=shift;

  return $self->search({},{
    join => 'event',
    order_by => 'event.scheduled_start'
  })
}

1;

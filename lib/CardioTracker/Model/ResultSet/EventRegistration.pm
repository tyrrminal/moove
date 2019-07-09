package CardioTracker::Model::ResultSet::EventRegistration;

use base qw(DBIx::Class::ResultSet);

sub for_user {
  my $self = shift;
  my ($user) = shift;

  return $self->search(
    {
      user_id => $user->id
    }
    );
}

sub visible_to {
  my $self = shift;
  my ($user) = shift;

  return $self->search(
    {
      -or => [
        is_public => 'Y',
        user_id   => $user->id
      ]
    }
    );
}

sub ordered {
  my $self = shift;
  my $direction = shift // '-asc';

  return $self->search(
    {},
    {
      join     => 'event',
      order_by => { $direction => 'event.scheduled_start'}
    }
    );
}

1;

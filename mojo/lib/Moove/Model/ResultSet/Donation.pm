package Moove::Model::ResultSet::Donation;
use v5.38;

use base       qw(DBIx::Class::ResultSet);
use List::Util qw(sum);

sub for_events_for_user ($self, $user) {
  return $self->search(
    {
      user_id => $user->id
    }, {
      join => 'user_event_activity'
    }
  );
}

sub ordered ($self) {
  return $self->search(
    undef, {
      order_by => {-asc => 'date'}
    }
  );
}

1;

package Moove::Model::ResultSet::Donation;
use strict;
use warnings;

use base qw(DBIx::Class::ResultSet);
use List::Util qw(sum);

use DCS::Constants qw(:existence);

use experimental qw(signatures postderef);

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

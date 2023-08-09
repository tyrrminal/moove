package Moove::Model::ResultSet::EventRegistration;
use v5.38;

use base qw(DBIx::Class::ResultSet);

sub with_user_activity ($self) {
  $self->search(
    {
      'user_event_activities.id' => {'<>' => undef},
    }, {
      join => 'user_event_activities',
    }
  );
}

sub without_user_activity ($self) {
  $self->search(
    {
      'user_event_activities.id' => {'=' => undef},
    }, {
      join => 'user_event_activities',
    }
  );
}

1;

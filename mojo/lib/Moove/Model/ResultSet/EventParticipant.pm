package Moove::Model::ResultSet::EventParticipant;
use v5.38;

use base qw(DBIx::Class::ResultSet);

sub for_event_activity ($self, $ea) {
  return $self->search(
    {
      'event_registration.event_activity_id' => $ea->id,
    }, {
      join => 'event_registration'
    }
  );
}

sub in_division ($self, $division) {
  return $self->search(
    {
      division_id => $division->id
    }
  );
}

sub of_gender ($self, $gender) {
  return $self->search(
    {
      gender_id => $gender->id
    }
  );
}

1;

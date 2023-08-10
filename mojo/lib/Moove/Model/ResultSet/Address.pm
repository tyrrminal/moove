package Moove::Model::ResultSet::Address;
use v5.38;

use base qw(DBIx::Class::ResultSet);

sub get_address ($self, %v) {
  return $self->find_or_create(
    {
      street1 => undef,
      street2 => undef,
      city    => $v{city},
      state   => $v{state},
      zip     => undef,
      phone   => undef,
      country => $v{country}
    }
  );
}

sub for_donations_to_user_by_person ($self, $user, $person) {
  return $self->search(
    {
      'person.id'                   => $person->id,
      'user_event_activity.user_id' => $user->id,
    }, {
      order_by => {-desc     => 'donations.date'},
      join     => {donations => ['user_event_activity', 'person']},
      collapse => 1
    }
  );
}

1;

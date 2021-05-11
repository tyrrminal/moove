package Moove::Model::ResultSet::Address;
use strict;
use warnings;

use base qw(DBIx::Class::ResultSet);

use DCS::Constants qw(:existence);

use experimental qw(signatures postderef);

sub find_address ($self, %v) {
  return $self->find_or_create(
    {
      street1 => $NULL,
      street2 => $NULL,
      city    => $v{city},
      state   => $v{state},
      zip     => $NULL,
      phone   => $NULL,
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

package Moove::Model::ResultSet::UserGoalFulfillmentActivity;
use strict;
use warnings;

use base qw(DBIx::Class::ResultSet);

use experimental qw(signatures postderef);

sub ordered($self, $direction = '-asc') {
  return $self->search({}, {
    join => 'activity',
    order_by => {$direction => 'activity.start_time'}
  });
}

1;
package Moove::Model::ResultSet::UserGoalFulfillmentActivity;
use v5.36;

use base qw(DBIx::Class::ResultSet);

sub ordered ($self, $direction = '-asc') {
  return $self->search(
    {},
    {
      join     => 'activity',
      order_by => {$direction => 'activity.start_time'}
    }
  );
}

1;

package CardioTracker::Model::ResultSet::UserGoalFulfillmentActivity;

use base qw(DBIx::Class::ResultSet);

sub ordered {
  my $self = shift;
  my ($direction) = (@_, '-asc');

  return $self->search({}, {
    join => 'activity',
    order_by => {$direction => 'activity.start_time'}
  });
}

1;
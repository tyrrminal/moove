package CardioTracker::Model::ResultSet::UserGoalFulfillment;

use base qw(DBIx::Class::ResultSet);

sub ordered {
  my $self = shift;

  $self->search({},{
    order_by => {'-asc' => 'date'}
  });
}

sub most_recent {
  my $self = shift;

  $self->search({},{
    order_by => {'-desc' => 'date'}
  })->first;
}

1;
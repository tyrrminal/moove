package Moove::Model::ResultSet::UserGoalFulfillment;

use base qw(DBIx::Class::ResultSet);

sub ordered {
  my $self = shift;
  my ($direction) = (@_, '-asc');

  $self->search(
    {},
    {
      order_by => {$direction => 'date'}
    }
  );
}

sub most_recent {
  my $self = shift;

  $self->search(
    {},
    {
      order_by => {'-desc' => 'date'}
    }
  )->first;
}

1;

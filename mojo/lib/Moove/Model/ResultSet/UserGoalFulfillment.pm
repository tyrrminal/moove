package Moove::Model::ResultSet::UserGoalFulfillment;
use v5.36;

use base qw(DBIx::Class::ResultSet);

sub ordered ($self, $direction = '-asc') {
  $self->search(
    {},
    {
      order_by => {$direction => 'date'}
    }
  );
}

sub most_recent ($self) {
  $self->search(
    {},
    {
      order_by => {'-desc' => 'date'}
    }
  )->first;
}

1;

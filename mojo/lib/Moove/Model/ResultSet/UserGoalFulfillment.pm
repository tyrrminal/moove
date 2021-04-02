package Moove::Model::ResultSet::UserGoalFulfillment;
use strict;
use warnings;

use base qw(DBIx::Class::ResultSet);

use experimental qw(signatures postderef);

sub ordered($self, $direction = '-asc') {
  $self->search(
    {},
    {
      order_by => {$direction => 'date'}
    }
  );
}

sub most_recent($self) {
  $self->search(
    {},
    {
      order_by => {'-desc' => 'date'}
    }
  )->first;
}

1;

package Moove::Model::ResultSet::EventPlacement;
use v5.36;

use base qw(DBIx::Class::ResultSet);

sub ordered ($self) {
  return $self->search(
    undef, {
      order_by => 'place'
    }
  );
}


1;

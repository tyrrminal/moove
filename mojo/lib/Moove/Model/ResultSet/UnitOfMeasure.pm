package Moove::Model::ResultSet::UnitOfMeasure;
use v5.38;

use base qw(DBIx::Class::ResultSet);

sub mile ($self) {
  return $self->find({abbreviation => 'mi'});
}

sub mph ($self) {
  return $self->find({abbreviation => 'mph'});
}

sub per_mile ($self) {
  return $self->find({abbreviation => '/mi'});
}

1;

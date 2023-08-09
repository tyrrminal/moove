package Moove::Model::ResultSet::ActivityResult;
use v5.38;

use base qw(DBIx::Class::ResultSet);

sub with_distance ($self) {
  return $self->search({distance_id => {'<>' => undef}});
}

sub needs_pace ($self) {
  return $self->search(
    {
      'pace'                        => undef,
      'base_activity_type.has_pace' => 'Y'
    }, {
      join => {activities => {activity_type => 'base_activity_type'}}
    }
  );
}

1;

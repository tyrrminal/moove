package Moove::Model::ResultSet::EventPlacementPartition;
use v5.36;

use base qw(DBIx::Class::ResultSet);

sub get_partitions ($self, $event_activity, $gender, $division) {
  my %p;
  $p{overall} = $self->app->model('EventPlacementPartition')
    ->find_or_create({event_activity => $event_activity, gender_id => undef, division_id => undef});
  $p{gender} =
    $self->app->model('EventPlacementPartition')
    ->find_or_create({event_activity => $event_activity, gender_id => $gender->id, division_id => undef})
    if ($gender);
  $p{division} =
    $self->app->model('EventPlacementPartition')
    ->find_or_create({event_activity => $event_activity, gender_id => undef, division_id => $division->id})
    if ($division);
  return %p;
}

sub for_event ($self, $event) {
  return $self->search(
    {
      event_id => $event->id
    }
  );
}

sub missing_count ($self) {
  return $self->search({count => {'=', undef}});
}

1;

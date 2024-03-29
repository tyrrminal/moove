package Moove::Model::ResultSet::EventPlacementPartition;
use v5.38;

use base qw(DBIx::Class::ResultSet);

sub get_partitions ($self, $event_activity, $gender, $division) {
  my %p;
  my $epp = $self->result_source->schema->resultset('EventPlacementPartition');
  $p{overall} = $epp->find_or_create({event_activity => $event_activity, gender_id => undef, division_id => undef});
  $p{gender}  = $epp->find_or_create({event_activity => $event_activity, gender_id => $gender->id, division_id => undef})
    if ($gender);
  $p{division} = $epp->find_or_create({event_activity => $event_activity, gender_id => undef, division_id => $division->id})
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

sub overall ($self) {
  return $self->search({gender_id => undef, division_id => undef})->first;
}

1;

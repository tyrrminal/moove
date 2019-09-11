package CardioTracker::Model::ResultSet::EventResultGroup;

use base qw(DBIx::Class::ResultSet);

use DCS::Constants qw(:boolean :existence);

sub for_event {
  my $self = shift;
  my ($event) = @_;

  return $self->search(
    {
      event_id => $event->id
    }
  );
}

sub missing_count {
  my $self = shift;
  return $self->search({count => {'=', $NULL}});
}

1;

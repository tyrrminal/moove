package CardioTracker::Model::ResultSet::Result;

use base qw(DBIx::Class::ResultSet);

use DCS::Constants qw(:existence);

sub for_event {
  my $self = shift;
  my ($event) = @_;

  return $self->search(
    {
      'activity.event_id' => $event->id
    }, {
      join => 'activity'
    }
  );
}

sub needs_pace {
  my $self = shift;

  return $self->search({pace => $NULL});
}

1;

package Moove::Model::ResultSet::CardioActivityResult;

use base qw(DBIx::Class::ResultSet);

use DCS::Constants qw(:existence);

sub for_event {
  my $self = shift;
  my ($event) = @_;

  return $self->search(
    {
      'activities.event_id' => $event->id
    }, {
      join => 'activities'
    }
  );
}

sub needs_pace {
  my $self = shift;

  return $self->search({pace => $NULL});
}

1;

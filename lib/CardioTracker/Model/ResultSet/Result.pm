package CardioTracker::Model::ResultSet::Result;

use base qw(DBIx::Class::ResultSet);

use DCS::Constants qw(:existence);

sub needs_pace {
  my $self=shift;

  return $self->search({ pace => $NULL });
}

1;

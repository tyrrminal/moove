package CardioTracker::Model::ResultSet::EventResultGroup;

use base qw(DBIx::Class::ResultSet);

use DCS::Constants qw(:boolean :existence);

sub missing_count {
  my $self = shift;
  return $self->search({count => {'=', $NULL}});
}

1;

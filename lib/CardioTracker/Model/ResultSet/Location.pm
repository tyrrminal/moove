package CardioTracker::Model::ResultSet::Location;

use base qw(DBIx::Class::ResultSet);

sub find_city_state {
  my $self=shift;
  my ($city,$state) = @_;

  return $self->find_or_create({
      street1 => $NULL,
      street2 => $NULL,
      city => $city,
      state => $state,
      zip => $NULL,
      phone => $NULL
    });
}

1;

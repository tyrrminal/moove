package CardioTracker::Model::ResultSet::Address;

use base qw(DBIx::Class::ResultSet);

sub find_address {
  my $self=shift;
  my %v = @_;

  return $self->find_or_create({
      street1 => $NULL,
      street2 => $NULL,
      city => $v{city},
      state => $v{state},
      zip => $NULL,
      phone => $NULL,
      country => $v{country}
    });
}

1;

package CardioTracker::Model::ResultSet::Person;
use base qw(DBIx::Class::ResultSet);

use Modern::Perl;

sub find_or_create_donor {
  my $self=shift;
  my ($first_name,$last_name) = @_;

  my ($person) = $self->search({
    first_name => $first_name,
    last_name => $last_name
  },{
    join => 'donations'
  })->first;
  $person = $self->create({
    first_name => $first_name,
    last_name => $last_name
  }) unless(defined($person));

  return $person;
}

1;

package Moove::Model::ResultSet::Person;
use v5.36;

use base qw(DBIx::Class::ResultSet);

use String::Util qw(trim);

sub get_person ($self, %attrs) {
  if (scalar(grep {defined} values(%attrs))) {
    return $self->create({firstname => $attrs{first_name}, lastname => $attrs{last_name}});
  } else {
    return $self->find_or_create(firstname => 'Unknown', lastname => 'Person');
  }
}

sub find_or_create_donor ($self, $first_name, $last_name) {
  my ($person) = $self->search(
    {
      first_name => $first_name,
      last_name  => $last_name
    }, {
      join => 'donations'
    }
  )->first;
  $person = $self->create(
    {
      first_name => $first_name,
      last_name  => $last_name
    }
    )
    unless (defined($person));

  return $person;
}

sub by_name ($self, $fname, $lname) {
  my $surround = sub ($str, $q = q{%}) {qq{$q$str$q}};
  my $rs       = $self;
  $rs = $rs->search({firstname => {-like => $surround->($fname)}}) if (defined($fname));
  $rs = $rs->search({lastname  => {-like => $surround->($lname)}}) if (defined($lname));
  return $rs;
}

sub who_donated_to_user ($self, $user) {
  return $self->search(
    {
      user_id => $user->id
    }, {
      prefetch => {donations => ['user_event_activity', 'address']},
    }
  );
}

1;

package CardioTracker::Model::ResultSet::Activity;
use base qw(DBIx::Class::ResultSet);

use Modern::Perl;

use DCS::Constants qw(:existence);

sub for_user {
  my $self=shift;
  my ($user) = shift;

  return $self->search({
    'user_activities.user_id' => $user->id
  },{
    'join' => 'user_activities'
  })
}

sub whole {
  my $self=shift;

  return $self->search({
    'whole_activity_id' => $NULL
  });
}

sub core {
  my $self=shift;

  return $self->search({
    '-or' => [
      'activity_type.description' => 'Run',
      'activity_type.description' => 'Ride'
    ]
  },{
    'join' => 'activity_type'
  })
}

sub by_type {
  my $self=shift;
  my ($type) = @_;

  return $self->search({
    'activity_type.description' => $type,
  },{
    'join' => 'activity_type'
  })
}

sub outdoor {
  my $self=shift;

  return $self->search({
    'activity_type.description' => {'!=' => 'Treadmill'}
  }, {
    'join' => 'activity_type'
  })
}

sub year {
  my $self=shift;
  my ($year) = @_;

  return $self->search(
    \['YEAR(start_time)=?', $year]
  );
}

sub completed {
  my $self=shift;

  return $self->search({},{ join => 'result' });
}

sub ordered {
  my $self=shift;

  return $self->search({}, { order_by => 'me.start_time' });
}

1;

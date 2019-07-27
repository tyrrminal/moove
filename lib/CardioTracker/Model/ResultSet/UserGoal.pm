package CardioTracker::Model::ResultSet::UserGoal;

use base qw(DBIx::Class::ResultSet);

sub for_user {
  my $self = shift;
  my ($user) = @_;

  return $self->search({
    user_id => $user->id
  });
}

sub of_type {
  my $self = shift;
  my ($type) = @_;

  return $self->search({
    'goal.activity_type_id' => $type->id
  },{
    join => 'goal'
  })
}

1;

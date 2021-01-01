package CardioTracker::Model::ResultSet::UserGoal;

use base qw(DBIx::Class::ResultSet);

sub fulfilled {
  my $self = shift;
  my ($direction) = (@_, '-asc');

  return $self->search(
    {},
    {
      join     => 'user_goal_fulfillments',
      order_by => {$direction => \['MAX(user_goal_fulfillments.date)']},
      group_by => 'me.id'
    }
  );
}

sub personal_records {
  my $self = shift;

  return $self->search(
    {
      'goal_comparator.superlative' => 'Y'
    }, {
      join => {goal => 'goal_comparator'}
    }
  );
}

sub achievements {
  my $self = shift;

  return $self->search(
    {
      'goal_comparator.superlative' => 'N'
    }, {
      join => {goal => 'goal_comparator'}
    }
  );
}

sub for_user {
  my $self = shift;
  my ($user) = @_;

  return $self->search(
    {
      user_id => $user->id
    }
  );
}

sub of_type {
  my $self = shift;
  my ($type) = @_;

  return $self->search(
    {
      -or => [
        'goal.activity_type_id' => $type->id,
        'goal.activity_type_id' => {'=', undef}
      ]
    }, {
      join => 'goal'
    }
  );
}

sub update_applicable_goals {
  my $self = shift;
  my ($activity) = @_;
  return unless (defined($activity->user));

  foreach my $ug ($self->for_user($activity->user)->of_type($activity->activity_type)) {
    $ug->update($activity);
  }
}

1;

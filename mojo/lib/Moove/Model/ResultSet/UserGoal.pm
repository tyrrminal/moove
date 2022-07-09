package Moove::Model::ResultSet::UserGoal;
use v5.36;

use base qw(DBIx::Class::ResultSet);

sub fulfilled ($self, $direction = '-asc') {
  return $self->search(
    {},
    {
      join     => 'user_goal_fulfillments',
      order_by => {$direction => \['MAX(user_goal_fulfillments.date)']},
      group_by => 'me.id'
    }
  );
}

sub personal_records ($self) {
  return $self->search(
    {
      'goal_comparator.superlative' => 'Y'
    }, {
      join => {goal => 'goal_comparator'}
    }
  );
}

sub achievements ($self) {
  return $self->search(
    {
      'goal_comparator.superlative' => 'N'
    }, {
      join => {goal => 'goal_comparator'}
    }
  );
}

sub for_user ($self, $user) {
  return $self->search(
    {
      user_id => $user->id
    }
  );
}

sub of_type ($self, $type) {
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

sub update_applicable_goals ($self, $activity) {
  return unless (defined($activity->user));

  foreach my $ug ($self->for_user($activity->user)->of_type($activity->activity_type)) {
    $ug->update($activity);
  }
}

1;

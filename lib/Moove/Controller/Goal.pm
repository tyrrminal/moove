package Moove::Controller::Goal;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use DCS::Constants qw(:boolean);

sub list($self) {
  my $c = $self->openapi->valid_input or return;

  my $user_id = $c->validation->param('user');

  if (my $u = $c->model('User')->find_user($user_id)) {
    my $goals = $u->user_goals->search({}, {join => 'goal', order_by => 'goal.activity_type_id, goal.name'});
    return $c->render(
      status  => 200,
      openapi => {
        personalRecords => [map {$_->to_hash(most_recent_fulfillment => $TRUE)} $goals->personal_records->all],
        achievements    => [
          map {
            $_->to_hash(
              fulfillments         => $TRUE,
              most_recent_activity => $TRUE,
              event                => sub {shift->event_registrations->visible_to($c->current_user) > 0}
              )
            } $goals->achievements->all
        ]
      }
    );
  }
}

sub get($self) {
  my $c = $self->openapi->valid_input or return;

  my $user_id = $c->validation->param('user');
  my $goal_id = $c->validation->param('goal');

  if (my $u = $c->model('User')->find_user($user_id)) {
    my $g = $u->user_goals->search({goal_id => $goal_id})->first->to_hash(
      fulfillments         => $TRUE,
      most_recent_activity => $TRUE,
      event                => sub {shift->event_registrations->visible_to($c->current_user) > 0}
    );

    return $c->render(
      status  => 200,
      openapi => $g
    );
  }
}

1;

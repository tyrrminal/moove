package CardioTracker::Controller::API::V1::User;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use DCS::Constants qw(:boolean);

sub get_summary($self) {
  my $c = $self->openapi->valid_input or return;
  my $user_id = $c->validation->param('user');

  if (my $u = $c->model('User')->find_user($user_id)) {
    my @recent = $u->activities->whole->ordered('-desc')->slice(0, 4);

    my @results = $c->model('CumulativeTotal')->search(
      {
        user_id => $u->id,
        year    => {'=', undef}
      }
    );

    my $reg = $u->event_registrations;
    my %e   = (
      previous => $reg->past->visible_to($c->current_user)->ordered('-desc')->first,
      next     => $reg->future->visible_to($c->current_user)->ordered('-asc')->first
    );
    foreach (keys(%e)) {
      if (defined($e{$_})) {$e{$_} = $e{$_}->to_hash(complete => $TRUE);}
      else                 {delete($e{$_});}
    }
    return $c->render(
      status  => 200,
      openapi => {
        user              => $u->to_hash,
        recent_activities => [map {$_->to_hash} @recent],
        events            => {%e},
        totals            => [map {$_->to_hash} @results]
      }
    );
  }

  return $c->render(
    status  => 404,
    openapi => {message => "User '$user_id' unknown"}
  );
}

sub get_goals($self) {
  my $c = $self->openapi->valid_input or return;

  my $user_id = $c->validation->param('user');

  if (my $u = $c->model('User')->find_user($user_id)) {

    my $s = $u->user_goals;
    my @goals;
    while (my $ug = $s->next) {
      my $g = $ug->goal->to_hash;
      $g->{fulfillments} = [map {$_->to_hash(activities => $FALSE)} $ug->user_goal_fulfillments];
      push(@goals, $g);
    }

    return $c->render(
      status  => 200,
      openapi => \@goals
    );
  }
}

sub get_goal($self) {
  my $c = $self->openapi->valid_input or return;

  my $user_id = $c->validation->param('user');
  my $goal_id = $c->validation->param('goal');

  if (my $u = $c->model('User')->find_user($user_id)) {
    my $ug = $u->user_goals->search({goal_id => $goal_id})->first;
    my $g = $ug->goal->to_hash;
    $g->{fulfillments} = [map {$_->to_hash(activities => $TRUE)} $ug->user_goal_fulfillments];

    return $c->render(
      status  => 200,
      openapi => $g
    );
  }
}

1;

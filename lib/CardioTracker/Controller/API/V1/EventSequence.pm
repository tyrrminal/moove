package CardioTracker::Controller::API::V1::EventSequence;
use Mojo::Base 'Mojolicious::Controller';

use DCS::Constants qw(:boolean);

sub list {
  my $self = shift;
  my $c = $self->openapi->valid_input or return;
  my $message;

  my $event_sqeuence_id = $c->validation->param('id');
  my $user_id           = $c->validation->param('user');
  my $search_field      = ($user_id =~ /\D/) ? 'username' : 'id';

  my $i = 0;
  if (my $u = $c->model('User')->find({$search_field => $user_id})) {
    my @events;
    foreach my $er (
      $c->model('EventRegistration')->in_sequence($event_sqeuence_id)->for_user($u)->visible_to($c->current_user)->ordered())
    {
      my $h = {
        registration => $er->to_hash(donations => $FALSE),
        event        => $er->event->to_hash
      };
      if (my $activity = $er->event->activities->search({user_id => $u->id}, {join => 'user_activities'})->first) {
        $h->{activity} = $activity->to_hash(event => $FALSE);

        if (my @results = $activity->result->event_results) {
          $h->{results} = [map {$_->to_hash} @results];
        }
      }

      push(@events, $h);
    }
    return $c->render(openapi => [@events]);
  } else {
    $message = "User not found";
  }

  return $c->render(
    status  => 404,
    openapi => {
      message => $message
    }
  );
}

1;

package CardioTracker::Controller::API::V1::Event;
use Mojo::Base 'Mojolicious::Controller';

use DCS::Constants qw(:boolean);

sub get {
  my $self = shift;
  my $c = $self->openapi->valid_input or return;
  my $message;

  my $event_id = $c->validation->param('id');
  my $user_id  = $c->validation->param('user');

  if (my $u = $c->model('User')->find_user($user_id)) {
    if (my ($er) = $c->model('EventRegistration')->search({event_id => $event_id})->for_user($u)->visible_to($c->current_user)) {
      my $all = $c->model('EventRegistration')->for_user($u)->visible_to($c->current_user);
      my %l   = (
        next => $all->after($er->event)->first,
        prev => $all->before($er->event)->first
      );
      foreach (keys(%l)) {
        if (defined($l{$_})) {
          $l{$_} = {id => $l{$_}->event->id, name => $l{$_}->event->description};
        } else {
          delete($l{$_});
        }
      }

      return $c->render(
        openapi => {
          event => $er->to_hash_complete(goals => $TRUE, donations => ($c->current_user->id == $u->id)),
          links => \%l
        }
      );
    } else {
      $message = "Event not found";
    }
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

sub list {
  my $self = shift;
  my $c = $self->openapi->valid_input or return;
  my $message;

  my $user_id = $c->validation->param('user');

  my $i = 0;
  if (my $u = $c->model('User')->find_user($user_id)) {
    my @events;
    foreach my $er ($c->model('EventRegistration')->for_user($u)->visible_to($c->current_user)->ordered('-desc')) {
      my $h = {
        registration => $er->to_hash,
        event        => $er->event->to_hash
      };
      if (my $activity = $er->event->activities->search({user_id => $u->id})->first) {
        $h->{activity} = $activity->to_hash;

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

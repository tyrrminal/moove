package CardioTracker::Controller::API::V1::Event;
use Mojo::Base 'Mojolicious::Controller';

use DCS::Constants qw(:boolean);

sub get {
  my $self = shift;
  my $c = $self->openapi->valid_input or return;
  my $message;

  my $event_id     = $c->validation->param('id');
  my $user_id      = $c->validation->param('user');
  my $search_field = ($user_id =~ /\D/) ? 'username' : 'id';

  if (my $u = $c->model('User')->find({$search_field => $user_id})) {
    if (my ($er) = $c->model('EventRegistration')->search({event_id => $event_id})->for_user($u)->visible_to($c->current_user)) {
      my $h = {
        registration => $er->to_hash,
        event        => $er->event->to_hash
      };
      if (my $activity = $er->event->activities->search({user_id => $u->id}, {join => 'user_activities'})->first) {
        $h->{activity} = $activity->to_hash(event => $FALSE);

        if (my @results = $activity->result->event_results) {
          $h->{results} = [map {$_->to_hash} @results];
        }
      }

      my $all = $c->model('EventRegistration')->for_user($u)->visible_to($c->current_user);
      my $sequence = $er->sequence->visible_to($c->current_user);
      my %l = (
        next =>  $all->after($er->event)->first,
        prev =>  $all->before($er->event)->first,
        sequence_next => $sequence->after($er->event)->first,
        sequence_prev => $sequence->before($er->event)->first
      );
      foreach (keys(%l)) {
        if(defined($l{$_})) {
          $l{$_} = { id => $l{$_}->event->id, name => $l{$_}->event->description};
        } else {
          delete($l{$_});
        }
      }

      return $c->render(openapi => {
        event => $h,
        links => \%l
      });
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
  my $search_field = ($user_id =~ /\D/) ? 'username' : 'id';

  my $i = 0;
  if (my $u = $c->model('User')->find({$search_field => $user_id})) {
    my @events;
    foreach my $er ($c->model('EventRegistration')->for_user($u)->visible_to($c->current_user)->ordered('-desc')) {
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
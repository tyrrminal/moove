package CardioTracker::Controller::Legacy;
use Mojo::Base 'Mojolicious::Controller';

sub cardio {
  my $self=shift;

  my $u = $self->app->current_user;
  my @activities = $self->app->model('Activity')->search({
    'user_activities.user_id' => $u->id
  },{
    'join' => [
      'user_activities',
      'result'
    ],
    'order_by' => 'me.start_time'
  })->all;

  $self->stash(activities => \@activities);
}

sub summary {

}

sub events {

}

1;

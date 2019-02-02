package CardioTracker::Command::import_activities;
use Mojo::Base 'Mojolicious::Command';

use Modern::Perl;
use Mojo::Util 'getopt';

use DateTime;
use DateTime::Span;
use DateTime::Format::Duration;

use CardioTracker::Import::Activity::RunKeeper;

use CardioTracker::Import::Helper::TextBalancedFix;

use DCS::Constants qw(:boolean :existence);
use Data::Dumper;

has 'description' => 'Import Cardio Activities from File';
has 'usage' => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE


sub run {
  my ($self, @args) = @_;
  local $| = 1;

  my $import_class= "CardioTracker::Import::Activity::";
  my $mode;

  my $user_id = 1;
  getopt(
    \@args,
    'runkeeper' => sub { $import_class .= 'RunKeeper' },
    'rkup1' => sub { $import_class .= 'RunKeeper'; $mode = 'points'; },
    'file=s' => \my $file,
    'user=s' => \$user_id,
  );

  say "You must specify an import file" && exit 1 unless(defined($file));
  say "You must identify the data source" && exit 1 unless($import_class->can('new'));

  my $user = $self->app->model('User')->find($user_id) // $self->app->model('User')->find({username => $user_id});

  say "You must specify a valid username or user ID" unless(defined($user));

  my $importer = $import_class->new(file => $file);
  if(defined($mode)) {
    if($mode eq 'points') {
      $self->import_points($importer,$user);
    }
  } else {
    $self->import_all($importer, $user);
  }
}

sub import_all {
  my $self=shift;
  my ($importer, $user) = @_;

  my @events = $self->app->model('Event')->all;
  my $act;
  ACTIVITY: foreach my $activity ($importer->fetch_activities()) {
    foreach my $e (@events) {
      next unless($e->event_type->activity_type->description eq $activity->{type});
      next unless($e->scheduled_start->clone->truncate(to => 'day') == $activity->{date}->clone->truncate(to => 'day'));

      if(DateTime::Span->from_datetime_and_duration(after => $e->scheduled_start, minutes => 30)->contains($activity->{date}) ||
         DateTime::Span->from_datetime_and_duration(before => $e->scheduled_start, minutes => 5)->contains($activity->{date})) {
        if(($act) = $e->activities->search({ 'participants.person_id' => $user->person->id },{ join => { result => 'participants' }})) {
          $self->update_event_activity($activity, $act); #event with imported results
        } else {
          $act = $self->import_activity($activity, $e); #event without results
        }
        next ACTIVITY;
      }
    }
    $act = $self->import_activity($activity); #non-event activity
  } continue {
    say "Importing ".$act->start_time->strftime('%F')." ".$act->activity_type->description;
    $user->add_to_activities($act);
  }
}

sub import_points {
  my $self=shift;
  my ($importer, $user) = @_;

  foreach my $activity ($importer->fetch_activities()) {
    my $act = $self->app->model('Activity')->search({ start_time => $activity->{date} })->first;
    say "Updating ".$act->start_time->strftime('%F')." ".$act->activity_type->description;
    $self->store_points($act, @{$activity->{activity_points}});
  }
}

sub update_event_activity {
  my $self=shift;
  my ($data, $activity) = @_;

  $activity->update({
    start_time => $data->{date},
          note => $data->{notes}
  });
  $activity->result->update({ heart_rate => $data->{heart_rate} });
  $activity->result->update({ pace => $data->{pace} }) unless(defined($activity->result->pace));
  $self->store_points($activity, @{$data->{activity_points}}) unless($activity->activity_points);
}

sub import_activity {
  my $self=shift;
  my ($activity, $event) = @_;

  my $result = $self->app->model('Result')->create({
    gross_time => $activity->{gross_time},
    net_time   => $activity->{net_time},
    pace       => $activity->{pace},
    heart_rate => $activity->{heart_rate} || $NULL
  });
  my $act = $self->app->model('Activity')->create({
    activity_type => $self->app->model('ActivityType')->find({description => $activity->{type}}),
    start_time    => $activity->{date},
    distance      => $self->app->model('Distance')->find_or_create_from_miles($activity->{distance}),
    result        => $result,
    note          => $activity->{notes},
    event_id      => defined($event) ? $event->id : $NULL
  });
  $self->store_points($act, @{$activity->{activity_points}});
  return $act;
}

sub store_points {
  my $self=shift;
  my ($act, @points) = @_;

  foreach my $ap (@points) {
    my $loc = $self->app->model('Location')->create({
      latitude => $ap->{lat},
      longitude => $ap->{lon}
    });
    $act->add_to_activity_points({
      location => $loc,
      timestamp => $ap->{time}
    });
  }
}

1;

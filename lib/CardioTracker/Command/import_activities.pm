package CardioTracker::Command::import_activities;
use Mojo::Base 'Mojolicious::Command', -signatures;

use Mojo::Util 'getopt';

use DateTime;
use DateTime::Span;
use DateTime::Format::Duration;

use CardioTracker::Import::Activity::RunKeeper;

use CardioTracker::Import::Helper::TextBalancedFix;

use DCS::Constants qw(:boolean :existence);
use Data::Dumper;

has 'description' => 'Import Cardio Activities from File';
has 'usage'       => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run ($self, @args) {
  local $| = 1;

  my $import_class = "CardioTracker::Import::Activity::";
  my $mode;

  my $user_id = 1;
  getopt(
    \@args,
    'runkeeper' => sub {$import_class .= 'RunKeeper'},
    'file=s'    => \my $file,
    'user=s'    => \$user_id,
  );

  say "You must specify an import file"   && exit 1 unless (defined($file));
  say "You must identify the data source" && exit 1 unless ($import_class->can('new'));

  my $user = $self->app->model('User')->find($user_id) // $self->app->model('User')->find({username => $user_id});

  say "You must specify a valid username or user ID" unless (defined($user));

  my $importer = $import_class->new(file => $file);
  if (defined($mode)) {
    if ($mode eq 'refid') {

    }
  } else {
    $self->import_all($importer, $user);
  }
}

sub import_all ($self, $importer, $user) {
  my @events = $self->app->model('Event')->all;
  my $act;
  foreach my $activity ($importer->fetch_activities()) {
    my $existing = $self->app->model('Activity')->search(
      {
        'activity_references.reference_id'  => $activity->{activity_id},
        'activity_references.import_class ' => $activity->{importer}
      }, {
        join => 'activity_references'
      }
    )->first;
    if ($existing) {
      say "Skipping " . $existing->start_time->strftime('%F') . " " . $existing->activity_type->description;
      next;
    }
    foreach my $e (@events) {
      next unless ($e->event_type->activity_type->description eq $activity->{type});
      next unless ($e->scheduled_start->clone->truncate(to => 'day') == $activity->{date}->clone->truncate(to => 'day'));

      if ( DateTime::Span->from_datetime_and_duration(after => $e->scheduled_start, minutes => 30)->contains($activity->{date})
        || DateTime::Span->from_datetime_and_duration(before => $e->scheduled_start, minutes => 5)->contains($activity->{date}))
      {
        if (($act) = $e->activities->search({'participants.person_id' => $user->person->id}, {join => {result => 'participants'}}))
        {
          $self->update_event_activity($activity, $act, $user);    #event with imported results
        } else {
          $act = $self->import_activity($activity, $user, $e);     #event without results
        }
        last;
      }
    }
    $act = $self->import_activity($activity, $user) unless ($act);    #non-event activity
    say "Importing " . $act->start_time->strftime('%F') . " " . $act->activity_type->description;
  }
}

sub import_refids ($self, $importer, $user) {
  foreach my $activity ($importer->fetch_activities()) {
    if (my $act = $self->app->model('Activity')->search({start_time => $activity->{date}})->first) {
      $self->app->model('ActivityReference')->create(
        {
          activity     => $act,
          reference_id => $activity->{activity_id},
          import_class => $activity->{importer}
        }
        );
    }
  }
}

sub update_event_activity ($self, $data, $activity, $user) {
  $activity->update(
    {
      user_id    => $user->id,
      start_time => $data->{date},
      note       => $data->{notes}
    }
  );
  $activity->result->update({heart_rate => $data->{heart_rate}});
  $activity->result->update({pace => $data->{pace}}) unless (defined($activity->result->pace));
  $self->store_points($activity, @{$data->{activity_points}}) unless ($activity->activity_points);
}

sub import_activity ($self, $activity, $user, $event = undef) {
  my $result = $self->app->model('Result')->create(
    {
      gross_time => $activity->{gross_time},
      net_time   => $activity->{net_time},
      pace       => $activity->{pace},
      heart_rate => $activity->{heart_rate} || $NULL
    }
  );
  my $act = $self->app->model('Activity')->create(
    {
      user_id       => $user->id,
      activity_type => $self->app->model('ActivityType')->find({description => $activity->{type}}),
      start_time    => $activity->{date},
      distance      => $self->app->model('Distance')->find_or_create_from_miles($activity->{distance}),
      result        => $result,
      temperature   => $activity->{temperature},
      note          => $activity->{notes},
      event_id      => defined($event) ? $event->id : $NULL
    }
  );
  $self->app->model('ActivityReference')->create(
    {
      activity     => $act,
      reference_id => $activity->{activity_id},
      import_class => $activity->{importer}
    }
  );
  $self->store_points($act, @{$activity->{activity_points}});
  return $act;
}

sub store_points ($self, $act, @points) {
  foreach my $ap (@points) {
    my $loc = $self->app->model('Location')->create(
      {
        latitude  => $ap->{lat},
        longitude => $ap->{lon}
      }
    );
    $act->add_to_activity_points(
      {
        location  => $loc,
        timestamp => $ap->{time}
      }
    );
  }
}

1;

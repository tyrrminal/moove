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

  my $import_class= "CardioTracker::Import::Activity::";

  my $user_id = 1;
  getopt(
    \@args,
    'runkeeper' => sub { $import_class .= 'RunKeeper' },
    'file=s' => \my $file,
    'user=s' => \$user_id,
  );

  say "You must specify an import file" && exit 1 unless(defined($file));
  say "You must identify the data source" && exit 1 unless($import_class->can('new'));

  my $user = $self->app->model('User')->find($user_id) // $self->app->model('User')->find({username => $user_id});

  say "You must specify a valid username or user ID" unless(defined($user));

  my $d = DateTime::Format::Duration->new( pattern => '%r' );

  my @event_results = map { $_->result } $user->person->participants;

  my $importer = $import_class->new();
  ACTIVITY: foreach my $activity ($importer->parse($file)) {
    foreach my $r ( @event_results) {
      next unless($activity->{type} eq $r->activity->activity_type->description);
      my $act_start = $r->activity->events->first->scheduled_start;
      next unless($activity->{date}->clone->truncate(to => 'day') == $act_start->clone->truncate(to => 'day'));
      
      my $a_span = DateTime::Span->from_datetime_and_duration(
        start    => $activity->{date}, 
        duration => $d->parse_duration($activity->{net_time})
      );
      my $e_span = DateTime::Span->from_datetime_and_duration(
        start    => $act_start, 
        duration => ($r->gross_time // $r->net_time)
      );
      if($a_span->contains($act_start) || $e_span->contains($activity->{date})) {
        #say "Skipping ", $r->activity->events->first->description;
        $self->import_user_activity($user,$activity,$r);
        next ACTIVITY;
      }
    }
    $self->import_user_activity($user,$activity);
  }
}

sub import_user_activity {
  my $self=shift;
  my ($user,$activity,$result) = @_;

  my $type = $self->app->model('ActivityType')->find({description => $activity->{type}});
  my $distance = $self->app->model('Distance')->find_or_create_from_miles($activity->{distance});

  my $a;
  if(defined($result)) {
    $result->start_time($activity->{date});
    $a = $result->activity;
  } else {
    $a = $self->app->model('Activity')->create({
      activity_type => $type,
      distance      => $distance
    });
    $self->app->model('Result')->create({
      activity   => $a,
      start_time => $activity->{date},
      gross_time => $activity->{gross_time},
      net_time   => $activity->{net_time},
      pace       => $activity->{pace}
    });
  }
  $user->add_to_activities($a);
}

1;

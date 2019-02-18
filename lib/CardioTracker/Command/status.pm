package CardioTracker::Command::status;
use Mojo::Base 'Mojolicious::Command';

use Modern::Perl;
use Mojo::Util 'getopt';

use DateTime;
use DateTime::Span;
use DateTime::Format::Duration;

use List::Util qw(sum);

use Term::ANSIColor;

use DCS::Constants qw(:boolean :existence);
use Data::Dumper;

has 'description' => 'Current cardio status';
has 'usage' => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE


sub run {
  my ($self, @args) = @_;
  local $| = 1;

  my %tz = (time_zone => 'America/New_York');
  my $now = DateTime->now(%tz);

  my $user_id = 1;
  my $activity_type;
  getopt(
    \@args,
    'type=s' => \$activity_type,
    'user=s' => \$user_id,
  );

  my $user = $self->app->model('User')->find($user_id) // $self->app->model('User')->find({username => $user_id});

  my $doy = $now->day_of_year;
  my $dom = $now->day;
  my $dow = $now->local_day_of_week;

  my $activities = $self->app->model('Activity')->for_user($user)->by_type($activity_type);

  my $year_activities = $activities->search({ start_time => {'>' => $now->clone->truncate(to => 'year')->strftime('%F') } });
  my $month_activities = $activities->search({ start_time => {'>' => $now->clone->truncate(to => 'month')->strftime('%F') } });
  my $week_activities = $activities->search({ start_time => {'>' => $now->clone->truncate(to => 'local_week')->strftime('%F') } });
  my $day_activities  = $activities->search({ start_time => {'>' => $now->strftime('%F') } });

  my $yd = sum(map { $_->distance->normalized_value } $year_activities->all) - $doy;
  my $md = sum(map { $_->distance->normalized_value } $month_activities->all) - $dom;
  my $wd = sum(map { $_->distance->normalized_value } $week_activities->all) - $dow;
  my $dd = sum(map { $_->distance->normalized_value } $day_activities->all) - 1;

  say $activity_type;
  print "   [Year]";
  print color('bold red') if($yd<0);
  say sprintf("%7s", sprintf("%+.2f", $yd) );
  print color('reset');
  print "  [Month]";
  print color('bold red') if($md<0);
  say sprintf("%7s", sprintf("%+.2f", $md) );
  print color('reset');
  print "   [Week]";
  print color('bold red') if($wd<0);
  say sprintf("%7s", sprintf("%+.2f", $wd));
  print color('reset');
  print "    [Day]";
  print color('bold red') if($dd<0);
  say sprintf("%7s", sprintf("%+.2f", $dd));
}

1;

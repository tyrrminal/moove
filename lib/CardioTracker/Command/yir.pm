package CardioTracker::Command::yir;
use Mojo::Base 'Mojolicious::Command';

use Modern::Perl;

use DateTime;
use DCS::Constants qw(:boolean :existence);
use Data::Dumper;
use Mojo::Util 'getopt';
use List::Util qw(min);
use Term::ANSIColor;
use DCS::DateTime::Extras;

has 'description' => 'Year in Review';
has 'usage' => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run {
  my ($self, @args) = @_;

  my $y;
  my $activity_type = 'Run';
  getopt(
    \@args,
    'type:s' => \$activity_type,
    'year:i' => \$y
  );
  $y = DateTime->now()->year() unless(defined($y));
  my $u = $self->app->model('User')->find({username => 'digicow'});
  my @activities = $self->app->model('Activity')->for_user($u)->whole->by_type($activity_type)->year($y)->ordered;

  my $mpd = 1;

  my $total = 0;
  my %months;
  my %weeks;
  foreach(@activities) {
    my $week_start = $_->start_time->start_of_week_in_year;
    my $k = $week_start->strftime('%F');
    $weeks{$k}->{date} = $week_start;
    $weeks{$k}->{distance} += $_->distance->normalized_value;

    my $month_start = $_->start_time->start_of_month;
    $k = $month_start->strftime('%F');
    $months{$k}->{date} = $month_start;
    $months{$k}->{distance} += $_->distance->normalized_value;

    $total += $_->distance->normalized_value;
  }

  print "$y\t";
  print_v($total, (min(DateTime->today(time_zone => 'local'),DateTime->new(time_zone => 'local', year => $y, month => 12, day => 31))->day_of_year)*$mpd);
  print "\n";
  foreach my $m (sort(keys(%months))) {
    my $d = $months{$m}->{date};
    print " ".$d->strftime('%b')."\t";
    print_v($months{$m}->{distance}, (DateTime->last_day_of_month(time_zone => 'local', year => $d->year, month => $d->month)->day)*$mpd);
    print "\n";
    my @mw = grep { $months{$m}->{date}->month == $weeks{$_}->{date}->month } keys(%weeks);
    foreach (sort(@mw)) {
      my $w = $weeks{$_};
      print "  ".$w->{date}->strftime('%d')."\t";
      print_v($w->{distance}, 7*$mpd);
      print "\n";
    }
  }
}

sub print_v {
  my ($t, $l) = @_;
  print color('bold red') if($t < $l);
  print sprintf("%6s", sprintf("%.2f",$t));
  print color('reset');
}

1;

package CardioTracker::Controller::Legacy;
use Mojo::Base 'Mojolicious::Controller';

use List::Util qw(max sum);

use DCS::DateTime::Extras;

use Data::Dumper;

sub cardio {
  my $self=shift;

  my $u = $self->app->model('User')->find({username => $self->stash('username')});
  my @activities = $self->app->model('Activity')->whole->for_user($u)->core->completed->ordered->all;

  $self->stash(activities => \@activities);
}

sub summary {
  my $self=shift;
  my $u = $self->app->model('User')->find({username => $self->stash('username')});
  my $now = DateTime->now;

  my $start = $self->app->model('Activity')->whole->for_user($u)->ordered->first->start_time;
  my @activities = $self->app->model('Activity')->whole->for_user($u)->core->completed->all;
  
  my $running_miles_per_day = 1;
  my $running_season_start = DateTime->new(year => $now->year, month =>  1, day => 1);
  my $running_season_end   = DateTime->new(year => $now->year, month => 12, day => 31);
  my $running_days = max(0, 1+$now->day_of_year - $running_season_start->day_of_year) - max(0, $now->day_of_year - $running_season_end->day_of_year);

  my $cycling_miles_per_day = 5;
  my $cycling_season_start = DateTime->new(year => $now->year, month =>  4, day => 1);
  my $cycling_season_end   = DateTime->new(year => $now->year, month => 10, day => 1);
  my $cycling_days = max(0, 1+$now->day_of_year - $cycling_season_start->day_of_year) - max(0, $now->day_of_year - $cycling_season_end->day_of_year);

  $self->stash(stats => {
    overall => {
      total_days => $now->delta_days($start)->in_units('days'), 
      total_years => $now->yearfrac($start),

      total_distance => sum(map { $_->distance->normalized_value } @activities),
      event_distance => sum(map { $_->distance->normalized_value } grep { defined($_->event) && defined($_->result) } @activities)
    },

    year => {
      day_of => $now->day_of_year,
      length => $now->year_length,

      run => {
        distance  => sum(map { $_->distance->normalized_value } grep { $_->is_running_activity && $_->start_time->year eq $now->year } @activities),
        goal      => $running_miles_per_day*$running_days,
      },
      ride => {
        distance => sum(map { $_->distance->normalized_value } grep { $_->is_cycling_activity && $_->start_time->year eq $now->year } @activities),
        goal     => $cycling_miles_per_day*$cycling_days
      }
    }
  });

  my $summary;
  foreach my $a (@activities) {
    my $t = lc($a->activity_type->description);
    my $yn = $a->start_time->year;
    my $qn = 'Qtr'.$a->start_time->quarter;
    my $mn = sprintf('%02d-',$a->start_time->mon).$a->start_time->month_abbr;

    foreach my $p ($summary->{overall},$summary->{years}->{$yn},$summary->{years}->{$yn}->{quarters}->{$qn},$summary->{years}->{$yn}->{quarters}->{$qn}->{months}->{$mn}) {
      $p->{$t}->{count}++;
      $p->{$t}->{distance} += $a->distance->normalized_value;
    }
  }

  $self->stash(summary => $summary);
}

sub events {
  my $self=shift;
  my $u = $self->app->model('User')->find({username => $self->stash('username')});

  my @reg = $self->app->model('EventRegistration')->for_user($u)->visible_to($self->app->current_user)->ordered->all;
  $self->stash(registrations => \@reg);
}

1;
 
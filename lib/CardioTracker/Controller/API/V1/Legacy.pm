package CardioTracker::Controller::API::V1::Legacy;
use Mojo::Base 'Mojolicious::Controller';

use DateTime;
use DateTime::Format::Duration;
use DCS::DateTime::Extras;
use List::Util qw(sum max max);

sub get_summary {
  my $c = shift->openapi->valid_input or return;
  my %tz = (time_zone => 'local');

  my $u = $c->app->model('User')->find({username => $c->validation->param('username')});
  return $c->render_error(404, "User not found") unless ($u);

  my $now   = DateTime->now(%tz);
  my $start = $c->app->model('Activity')->whole->for_user($u)->ordered->first->start_time;

  my $running_miles_per_day = 1;
  my $running_season_start  = DateTime->new(year => $now->year, month => 1, day => 1, %tz);
  my $running_season_end    = DateTime->new(year => $now->year, month => 12, day => 31, %tz);
  my $running_days          = max(0, 1 + $now->day_of_year - $running_season_start->day_of_year)
    - max(0, $now->day_of_year - $running_season_end->day_of_year);

  my $cycling_miles_per_day = 10;
  my $cycling_season_start  = DateTime->new(year => $now->year, month => 4, day => 1, %tz);
  my $cycling_season_end    = DateTime->new(year => $now->year, month => 10, day => 1, %tz);
  my $cycling_days          = max(0, 1 + $now->day_of_year - $cycling_season_start->day_of_year)
    - max(0, $now->day_of_year - $cycling_season_end->day_of_year);

  my @activities = $c->app->model('Activity')->whole->for_user($u)->core->completed->ordered->all;
  my $summary;
  foreach my $a (@activities) {
    my $t     = $a->activity_type->description;
    my $yn    = $a->start_time->year;
    my $qn    = 'Qtr' . $a->start_time->quarter;
    my $mn    = sprintf('%02d-', $a->start_time->mon) . $a->start_time->month_abbr;
    my $wk    = $a->start_time->start_of_week_in_year;
    my $qn_wk = 'Qtr' . $wk->quarter;
    my $mn_wk = sprintf('%02d-', $wk->mon) . $wk->month_abbr;
    my $wk_no = $wk->day;

    foreach my $p (
      $summary,
      $summary->{years}->{$yn},
      $summary->{years}->{$yn}->{quarters}->{$qn},
      $summary->{years}->{$yn}->{quarters}->{$qn}->{months}->{$mn},
      $summary->{years}->{$yn}->{quarters}->{$qn_wk}->{months}->{$mn_wk}->{weeks}->{$wk_no}
      )
    {
      $p->{$t}->{count}++;
      $p->{$t}->{distance} += $a->distance->normalized_value;
    }
  }

  return $c->render(
    openapi => {
      activities => $summary,
      goals      => {
        Run  => $running_miles_per_day * $running_days,
        Ride => $cycling_miles_per_day * $cycling_days
      },
      overall => {
        since_start => {
          days           => $now->delta_days($start)->in_units('days'),
          years          => $now->yearfrac($start),
          distance       => sum(map {$_->distance->normalized_value} @activities),
          event_distance => sum(map {$_->distance->normalized_value} grep {defined($_->event) && defined($_->result)} @activities)
        },
        ytd => {
          days    => $now->day_of_year,
          days_of => $now->year_length,
        }
      }
    }
  );
}

sub get_activities {
  my $c = shift->openapi->valid_input or return;

  my $u = $c->app->model('User')->find({username => $c->validation->param('username')});
  return $c->render_error(404, "User not found") unless ($u);

  my ($page, $per_page) = ($c->validation->param('page') || 1, $c->validation->param('perPage') || 10);
  my $offset = max($page - 1, 0) * $per_page;

  my @activities;
  my %max = map {$_->description => undef} $c->app->model('ActivityType')->all;
  my $i = 0;
  foreach
    my $activity ($c->app->model('Activity')->whole->for_user($u)->core->completed->ordered->slice(0, $offset + $per_page - 1)->all)
  {
    my $t         = $activity->activity_type->description;
    my $prior_max = $max{$t};
    if ($activity->distance->normalized_value > (defined($prior_max) ? $prior_max->distance->normalized_value : 0)) {
      $max{$t} = $activity;
    }
    next unless (++$i > $offset);

    my $a = $activity->to_hash;
    $a->{prior_distance_pr} = $prior_max->to_hash if (defined($prior_max));
    push(@activities, $a);
  }

  return $c->render(
    openapi => {
      activities => \@activities,
      _meta      => {
        page    => $page,
        perPage => $per_page,
        count   => scalar @activities
      }
    }
    );
}

1;

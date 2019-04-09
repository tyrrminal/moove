package CardioTracker::Controller::API::V1::Legacy;
use Mojo::Base 'Mojolicious::Controller';

use DateTime::Format::Duration;
use DCS::DateTime::Extras;
use List::Util qw(sum max max);

sub get_summary {
  my $c = shift->openapi->valid_input or return;

  my $u = $c->app->model('User')->find({username => $c->validation->param('username')});
  return $c->render_error(404, "User not found") unless($u);

  my @activities = $c->app->model('Activity')->whole->for_user($u)->core->completed->ordered->all;
  my $summary;
  foreach my $a (@activities) {
    my $t = $a->activity_type->description;
    my $yn = $a->start_time->year;
    my $qn = 'Qtr'.$a->start_time->quarter;
    my $mn = sprintf('%02d-',$a->start_time->mon).$a->start_time->month_abbr;
    my $wk = $a->start_time->start_of_week_in_year;
    my $qn_wk = 'Qtr'.$wk->quarter;
    my $mn_wk = sprintf('%02d-',$wk->mon).$wk->month_abbr;
    my $wk_no = $wk->day;

    foreach my $p (
      $summary, 
      $summary->{years}->{$yn}, 
      $summary->{years}->{$yn}->{quarters}->{$qn}, 
      $summary->{years}->{$yn}->{quarters}->{$qn}->{months}->{$mn}, 
      $summary->{years}->{$yn}->{quarters}->{$qn_wk}->{months}->{$mn_wk}->{weeks}->{$wk_no}
    ) {
      $p->{$t}->{count}++;
      $p->{$t}->{distance} += $a->distance->normalized_value;
    }
  }
  
  return $c->render(openapi => $summary);
}

sub get_activities {
  my $c = shift->openapi->valid_input or return;

  my $u = $c->app->model('User')->find({username => $c->validation->param('username')});
  return $c->render_error(404, "User not found") unless($u);

  my ($page,$per_page) = ($c->validation->param('page') || 0, $c->validation->param('perPage') || 10);
  my $offset = max($page-1,0)*$per_page;

  my @activities;
  my %max = map { $_->description => 0 } $c->app->model('ActivityType')->all;
  my $i=0;
  foreach my $activity ($c->app->model('Activity')->whole->for_user($u)->core->completed->ordered->slice(0,$offset+$per_page-1)->all) {
    my $t = $activity->activity_type->description;
    my $prior_max = $max{$t};
    $max{$t} = max($max{$t}, $activity->distance->normalized_value);
    next unless(++$i>$offset);
    my @keys = $activity->is_running_activity ? qw(running run_max) : qw(cycling cycling_max);
    my $a = {
      date => $activity->start_time->strftime('%D'),
      type => $t,
      $keys[0] => $activity->distance->normalized_value,
      $keys[1] => $prior_max,
      event_id => $activity->has_event_visible_to($c->app->current_user) ? $activity->event->id : undef,
      event_name => $activity->has_event_visible_to($c->app->current_user) ? $activity->event->name : undef
    };
    
    push(@activities, $a);
  }

  return $c->render(openapi => {
    activities => \@activities,
    _meta => {
      page => $page,
      perPage => $per_page,
      count => scalar @activities,
      distance_units => $c->app->model('UnitOfMeasure')->normalization_unit->abbreviation
    }
  })
}

sub get_events {
  my $c = shift->openapi->valid_input or return;
  my $now = DateTime->now(time_zone => 'local');
  my $fmt = DateTime::Format::Duration->new(pattern => '%T', normalise => 1);

  my $u = $c->app->model('User')->find({username => $c->validation->param('username')});
  return $c->render_error(404, "User not found") unless($u);
  my (@past,@future);

  foreach my $er ($c->app->model('EventRegistration')->for_user($u)->visible_to($c->app->current_user)->ordered) {
    my $event = $er->event;
    my $base = {
      name => $event->name,
      date => $event->scheduled_start->strftime('%FT%T'),
      event_type => $event->event_type->description,
      distance => $event->distance->description,
      fee => $er->fee,
      registered => $er->registered,
      fr_min => $er->fundraising_minimum,
      fr_raised => sum(map { $_->amount } $er->donations)
    };

    if($event->scheduled_start < $now) {
      my $r = {};
      my $activity = $event->activities->search({ 'user_activities.user_id' => $u->id }, { join => 'user_activities' })->first;
      if($activity) {
        
        my $result = $activity->result;
        if($result) {
          $r = {
            distance => $activity->distance->description_normalized,
            time => $fmt->format_duration($result->net_time)
          };
          if($activity->is_running_activity) {
            $r->{pace} = $fmt->format_duration($result->pace)
          } elsif($activity->is_cycling_activity) {
            $r->{speed} = sprintf('%.02f', $result->speed)
          }
        }
      }

      push(@past, {
        %$base,
        result => $r
      })
    } else {
      my $days = $now->delta_days($event->scheduled_start)->in_units('days');
      push(@future, {
        %$base,
        countdown => {
          days => $days,
          weeks => $c->app->dec_format($days/7, 1),
          months => $c->app->dec_format($event->scheduled_start->yearfrac($now)*12, 1)
        }
      });
    }
  }

  return $c->render(openapi => {
    past_events => \@past,
    future_events => \@future
  });
}

1;

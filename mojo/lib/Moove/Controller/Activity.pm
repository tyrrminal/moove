package Moove::Controller::Activity;
use Mojo::Base 'DCS::API::Base::ModelController';

use Role::Tiny::With;
with 'DCS::API::Role::Rest::Collection';
with 'Moove::Controller::Role::ModelEncoding::Activity';

use boolean;
use List::Util qw(sum min max);

use Data::Printer {
  filters => {
    'DateTime' => sub {$_[0]->ymd},
  }
};

use experimental qw(signatures postderef switch);

no strict 'refs';

sub resultset ($self, @args) {
  my $rs = $self->SUPER::resultset(@args);
  $rs = $rs->search(
    undef, {
      prefetch => [
        {activity_result => [{distance => 'unit_of_measure'}]},
        'workout',
        {activity_type => ['base_activity_type', 'activity_context']}
      ]
    }
  );

  my $user = $self->model('User')->find($self->validation->param('userID') || $self->current_user->id);
  return $self->render_not_found('User') unless ($user);
  $rs = $rs->for_user($user)->visible_to($self->current_user);

  if (my $workout_id = $self->validation->param('workoutID')) {
    my $workout = $self->model_find(Workout => $workout_id) or return $self->render_not_found('Workout');
    $rs = $rs->in_workout($workout);
  }
  if (my $activity_type_id = $self->validation->param('activityTypeID')) {
    my $activity_type = $self->model_find(ActivityType => $activity_type_id) or return $self->render_not_found('ActivityType');
    $rs = $rs->activity_type($activity_type);
  }
  if (my $start_date = $self->validation->param('start')) {
    $rs = $rs->after_date($start_date);
  }
  if (my $end_date = $self->validation->param('end')) {
    $rs = $rs->before_date($end_date);
  }

  return $rs;
}

sub summary($self) {
  return unless ($self->openapi->valid_input);

  my $user = $self->current_user;
  if (defined($self->validation->param('userID'))) {
    $user = $self->model_find(User => $self->validation->param('userID')) or return $self->render_not_found('User');
  }
  my $activity_type = $self->model_find(ActivityType => $self->validation->param('activityTypeID'));
  my $period        = $self->validation->param('period');
  my $showEmpty     = $self->validation->param('includeEmpty') // false;

  my $activities = $self->resultset->whole->ordered;
  my $start      = $self->parse_api_date($self->validation->param('start'))
    // $self->model('Activity')->for_user($user)->ordered->first->start_time->clone->truncate(to => 'day');
  my $end = $self->parse_api_date($self->validation->param('end')) // DateTime->today;

  my @summaries;
  foreach my $p (periods_in_range($period, $start, $end)) {
    my $period_activities = $activities->after_date($p->{start})->before_date($p->{end});
    next unless ($period_activities->count || $showEmpty);
    my $summary = {
      period => {daysInPeriod => $p->{end}->delta_days($p->{start})->delta_days, $p->{t}->%*},
      count  => $period_activities->count
    };
    push(@summaries, $summary);
    if ($activity_type->base_activity_type->has_distance) {
      my @distances =
        map  {$_->activity_result->distance->normalized_value}
        grep {$_->activity_type->base_activity_type->has_distance} $period_activities->all;
      $summary->{distance} = {map {$_ => &$_(@distances) // 0} qw(sum max min)};
    }
  }

  return $self->render(openapi => [@summaries]);
}

sub periods_in_range ($period, $start, $end) {
  my @p;
  given ($period) {
    when ('all') {@p = ({start => $start, end => $end, t => {}})}
    when ('year') {
      my $o = $start->clone->truncate(to => 'year');
      push(
        @p, {
          t => {year => $o->year},
          start => max($start, $o->clone),
          end => min($end, $o->add(years => 1)->clone)
        }
        )
        while ($o < $end);
    }
    when ('quarter') {
      my $o = $start->clone->truncate(to => 'quarter');
      push(
        @p, {
          t => {
            year    => $o->year,
            quarter => $o->quarter,
          },
          start => max($start, $o->clone),
          end => min($end, $o->add(months => 3)->clone)
        }
        )
        while ($o < $end);
    }
    when ('month') {
      my $o = $start->clone->truncate(to => 'month');
      $o->subtract(months => 1)
        unless ($o->day_of_week == 7);    # back up a month unless the week starts on Sunday
      push(
        @p, {
          t => {
            year    => $o->year,
            quarter => $o->quarter,
            month   => $o->month,
          },
          start => max($start, $o->clone),
          end => min($end, $o->add(months => 1)->clone)
        }
        )
        while ($o < $end);
    }
    when ('week') {
      my $o = $start->clone->truncate(to => 'week');
      push(
        @p, {
          t => {
            year        => $o->week_year,
            quarter     => $o->quarter,
            month       => $o->month,
            weekOfMonth => $o->week_of_month,
            weekOfYear  => $o->week_number,
          },
          start => max($start, $o->clone),
          end => min($end, $o->add(weeks => 1)->clone)
        }
        )
        while ($o < $end);
    }
  }
  return @p;
}

1;

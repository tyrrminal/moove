package Moove::Controller::Activity;
use v5.36;

use Mojo::Base 'DCS::Base::API::Model::Controller';

use Role::Tiny::With;
with 'DCS::Base::Role::Rest::Collection', 'DCS::Base::Role::Rest::Entity';
with 'Moove::Controller::Role::ModelEncoding::Activity';
with 'Moove::Role::Import::Activity';

use Module::Util qw(module_path);
use List::Util   qw(sum min max);
use DCS::DateTime::Extras;
use Syntax::Keyword::Try;
use Mojo::Exception qw(raise);

use HTTP::Status qw(:constants);

use experimental qw(builtin);

sub decode_model ($self, $data) { }

sub effective_user ($self) {
  my $user = $self->current_user;
  if (my $username = $self->validation->param('username')) {
    $user = $self->model('User')->find({username => $username});
  }
  return $user;
}

sub resultset ($self, %args) {
  my $rs = $self->SUPER::resultset();
  $rs = $rs->search(
    undef, {
      prefetch => [
        {activity_result => [{distance => 'unit_of_measure'}, 'normalized_distance']},
        'workout',
        {activity_type => ['base_activity_type', 'activity_context']}
      ]
    }
  );

  if ($self->validation->param('combine') // $args{combine} // builtin::true) {
    $rs = $rs->whole;
  } else {
    $rs = $rs->uncombined;
  }

  $rs = $rs->for_user($self->effective_user)->visible_to($self->current_user);

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

sub custom_sort_for_column ($self, $col_name) {
  return 'normalized_distance.value'  if ($col_name eq 'distance');
  return 'activity_result.net_time'   if ($col_name eq 'time');
  return 'activity_result.pace'       if ($col_name eq 'pace');
  return 'activity_result.speed'      if ($col_name eq 'speed');
  return 'activity_result.start_time' if ($col_name eq 'startTime');
  return undef;
}

sub summary ($self) {
  return unless ($self->openapi->valid_input);
  my $today  = DateTime->today(time_zone => 'local');
  my $period = $self->validation->param('period');

  try {
    my $unit = $self->model('UnitOfMeasure')->search({normal_unit_id => undef, abbreviation => 'mi'})->first;

    my @activities = $self->resultset->completed->ordered->all;

    my $start = $self->parse_api_date($self->validation->param('start'))
      // (@activities > 0 ? $activities[0]->activity_result->start_time->truncate(to => 'day') : $today);
    my $end = $self->_end_of_period($start, $period) // $today;
    $end->add(days => 1) if ($start == $end);

    my $ars = $self->resultset()->before_date($end)->completed->ordered;
    my $ers = $self->resultset(combine => builtin::false)->before_date($end)->has_event;
    my $una = $self->effective_user->user_nominal_activities->search({year => defined($period) ? $start->year : undef});

    my @activity_summaries;
    foreach ($self->app->model('ActivityType')->all) {
      my $sl      = $ars->activity_type($_);
      my $nominal = $una->search({activity_type_id => $_->id})->first;
      my %nom;
      if (defined($nominal)) {
        my $pd = $nominal->per_day;
        %nom = (nominal => {(map {$_ => $pd->{$_} * $nominal->days_in_range_between_dates($start, $end)} keys($pd->%*))});
      }
      push(
        @activity_summaries, {
          activityTypeID => $_->id,
          distance       => $sl->total_distance,
          unitID         => $unit->id,
          %nom
        }
        )
        if ($sl->count || defined($nominal));
    }

    return $self->render(
      openapi => {
        period => {
          daysElapsed => min($end, $today)->delta_days($start)->delta_days,
          # daysElapsed => min(0, DateTime->today(time_zone => 'local')->delta_days($start)->delta_days),
          defined($period) ? (daysTotal => _days_in_period($period, $start)) : (),
          years => $end->yearfrac($start),
        },
        activities => [
          {
            activityTypeID => undef,
            distance       => $ars->total_distance,
            unitID         => $unit->id,
            eventDistance  => $ers->total_distance,
          },
          @activity_summaries
        ]
      }
    );
  } catch ($e) {
    $self->render_error(HTTP_BAD_REQUEST, $e->can('message') ? $e->message : $e)
  }
}

sub slice ($self) {
  return unless ($self->openapi->valid_input);

  my $user = $self->current_user;
  if (defined($self->validation->param('userID'))) {
    $user = $self->model_find(User => $self->validation->param('userID')) or return $self->render_not_found('User');
  }
  my $activity_type = $self->model_find(ActivityType => $self->validation->param('activityTypeID'));
  my $period        = $self->validation->param('period');
  my $showEmpty     = $self->validation->param('includeEmpty') // builtin::false;

  my $activities = $self->resultset->whole->ordered;
  my $start      = $self->parse_api_date($self->validation->param('start'))
    // $self->model('Activity')->for_user($user)->ordered->first->start_time->clone->truncate(to => 'day');
  my $end = DateTime->today->add(days => 1)->subtract(seconds => 1);

  my @summaries;
  my $i   = 0;
  my @all = $activities->all;
  foreach my $p (periods_in_range($period, $start, $end)) {
    my @period_activities;
    while (defined($all[$i]) && $all[$i]->start_time < $p->{end}) {
      push(@period_activities, $all[$i++]);
    }
    next unless (@period_activities || $showEmpty);
    my $slice = {
      period => {
        daysInPeriod => max(1, $p->{end}->delta_days($p->{start})->delta_days),
        start        => $p->{start}->strftime('%F'),
        end          => $p->{end}->strftime('%F'),
        $p->{t}->%*
      },
      count => scalar @period_activities
    };
    push(@summaries, $slice);
    if ($activity_type->base_activity_type->has_distance) {
      my @distances =
        map {$_->activity_result->distance->normalized_value}
        grep {$_->activity_type->base_activity_type->has_distance} @period_activities;
      $slice->{distance} = {
        sum => sum(@distances) // 0,
        max => max(@distances) // 0,
        min => min(@distances) // 0,
      };
    }
  }

  return $self->render(openapi => [@summaries]);
}

sub periods_in_range ($period, $start, $end) {
  my @p;
  if    ($period eq 'all') {@p = ({start => $start, end => $end, t => {}})}
  elsif ($period eq 'year') {
    my $o = $start->clone->truncate(to => 'year');
    push(
      @p, {
        t     => {year => $o->year},
        start => max($start, $o->clone),
        end   => min($end, $o->add(years => 1)->clone)
      }
      )
      while ($o < $end);
  } elsif ($period eq 'quarter') {
    my $o = $start->clone->truncate(to => 'quarter');
    push(
      @p, {
        t => {
          year    => $o->year,
          quarter => $o->quarter,
        },
        start => max($start, $o->clone),
        end   => min($end, $o->add(months => 3)->clone)
      }
      )
      while ($o < $end);
  } elsif ($period eq 'month') {
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
        end   => min($end, $o->add(months => 1)->clone)
      }
      )
      while ($o < $end);
  } elsif ($period eq 'week') {
    my $o = $start->clone->truncate(to => 'local_week');
    push(
      @p, {
        t => {
          year        => $o->year,
          quarter     => $o->quarter,
          month       => $o->month,
          weekOfMonth => $o->week_of_month,
          weekOfYear  => $o->clone->add(days => 1)->week_number,
        },
        start => max($start, $o->clone),
        end   => min($end, $o->add(weeks => 1)->clone)
      }
      )
      while ($o < $end);
  }
  return @p;
}

sub import ($self) {
  return unless ($self->openapi->valid_input);
  my @activities = ();

  my $asset = $self->param('file')->asset;
  my $ds    = $self->model_find(ExternalDataSource => $self->param('externalDataSourceID'))
    or $self->render_not_found('ExternalDataSource');

  my $import_class = $ds->import_class;
  require(module_path($import_class));
  my $importer = $import_class->new();

  foreach my $activity ($importer->get_activities($asset)) {
    my ($activity, $is_existing) = $self->import_activity($activity, $self->current_user);
    $activity = $self->encode_model($activity);
    $activity->{isNew} = !$is_existing;
    push(@activities, $activity);
  }

  return $self->render(openapi => \@activities);
}

sub merge ($self) {
  return unless ($self->openapi->valid_input);

  try {
    my @to_merge;
    foreach ($self->req->json->@*) {
      my $activity = $self->model('Activity')->search({'me.id' => $_->{id}})->writable_by($self->current_user)->first
        or return $self->render_not_found('Activity');
      push(@to_merge, $activity);
    }

    my $activity = $self->model('Activity')->merge(@to_merge);
    return $self->render(openapi => $self->encode_model($activity));
  } catch ($e) {
    return $self->render_error(HTTP_BAD_REQUEST, $e)
  }
}

sub _end_of_period ($self, $start, $period) {
  return undef if (!defined($period));

  my $tomorrow = DateTime->today(time_zone => 'local')->add(days => 1);
  my $offset   = $period eq 'week' ? 1 : 0;
  my $end =
    $start->clone->add(days => $offset)->truncate(to => $period)->add("${period}s" => 1)->subtract(days => $offset);
  return $end if ($start > DateTime->now(time_zone => 'local'));
  return min($end, $tomorrow);
}

sub _days_in_period ($period, $period_start) {
  return $period_start->year_length  if ($period eq 'year');
  return $period_start->month_length if ($period eq 'month');
  return 7                           if ($period eq 'week');
  return 1;
}

1;

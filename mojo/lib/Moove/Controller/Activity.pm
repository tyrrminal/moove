package Moove::Controller::Activity;
use Mojo::Base 'DCS::API::Base::ModelController';

use Role::Tiny::With;
with 'DCS::API::Role::Rest::Collection';
with 'Moove::Controller::Role::ModelEncoding::Activity';
with 'Moove::Role::Import::Activity';

use boolean;
use Module::Util qw(module_path);
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
  my $i   = 0;
  my @all = $activities->all;
  foreach my $p (periods_in_range($period, $start, $end)) {
    my @period_activities;
    while (defined($all[$i]) && $all[$i]->start_time < $p->{end}) {
      push(@period_activities, $all[$i++]);
    }
    next unless (@period_activities || $showEmpty);
    my $summary = {
        start        => $p->{start}->strftime('%F'),
        end          => $p->{end}->strftime('%F'),
    };
    push(@summaries, $summary);
    if ($activity_type->base_activity_type->has_distance) {
      my @distances =
        map  {$_->activity_result->distance->normalized_value}
        grep {$_->activity_type->base_activity_type->has_distance} @period_activities;
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
      my $o = $start->clone->truncate(to => 'local_week');
      push(
        @p, {
          t => {
            year        => $o->year,
            quarter     => $o->quarter,
            month       => $o->month,
            weekOfMonth => $o->week_of_month,
            weekOfYear  => ($o->year < $o->week_year) ? $o->clone->subtract(weeks => 1)->week_number + 1 : $o->week_number,
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

sub import($self) {
  return unless ($self->openapi->valid_input);
  my @activities = ();

  my $asset = $self->param('file')->asset;
  my $ds = $self->model_find(ExternalDataSource => $self->param('externalDataSourceID'))
    or $self->render_not_found('ExternalDataSource');

  my $import_class = $ds->import_class;
  require(module_path($import_class));
  my $importer = $import_class->new();

  foreach my $activity ($importer->get_activities($asset)) {
    push(@activities, $self->import_activity($activity, $self->current_user));
  }

  return $self->render(openapi => $self->encode_model([@activities]));
}

1;

package Moove::Controller::Activity;
use v5.36;

use Mojo::Base 'DCS::Base::API::Model::Controller';

use Role::Tiny::With;
with 'DCS::Base::Role::Rest::Collection', 'DCS::Base::Role::Rest::Entity';
with 'Moove::Controller::Role::ModelEncoding::Activity', 'Moove::Controller::Role::ModelEncoding::Activity::UserEventActivity';
with 'Moove::Role::Import::Activity';
with 'Moove::Role::Unit::Conversion';

use Data::UUID;
use DateTime::Format::ISO8601;
use Module::Util qw(module_path);
use List::Util   qw(sum min max);
use DCS::DateTime::Extras;
use Syntax::Keyword::Try;
use Mojo::Exception qw(raise);
use Mojo::JSON qw(decode_json);
use JSON::Validator;

use syntax 'junction';

use DCS::Util::NameConversion qw(convert_hash_keys camel_to_snake);

use HTTP::Status   qw(:constants);
use DCS::Constants qw(:symbols);

use builtin      qw(true false);
use experimental qw(builtin for_list);

sub decode_model ($self, $data) {
  my $d  = {convert_hash_keys($data->%*, \&camel_to_snake)};
  my $at = $self->model('ActivityType')->find($d->{activity_type_id});
  return undef unless ($at);

  if (exists($d->{distance})) {
    if (defined($d->{distance})) {
      my $distance = $self->model('Distance')->find_or_create_in_units($d->{distance}->{value},
        $self->model('UnitOfMeasure')->find($d->{distance}->{unit_of_measure_id}));
      $d->{distance_id} = $distance->id;
    } else {
      $d->{distance_id} = undef;
    }
  }
  $d->{pace}       = $self->normalized_pace($d->{pace})   if (defined($d->{pace}));
  $d->{speed}      = $self->normalized_speed($d->{speed}) if (defined($d->{speed}));
  $d->{start_time} = DateTime::Format::ISO8601->parse_datetime($d->{start_time})->strftime('%FT%T');

  #<<< no tidy because it can't handle for-list syntax properly yet
  foreach my ($field, $key) ((group => "group_num", set => "set_num")) {
    $d->{$key} = $d->{$field} if (exists($d->{$field}));
  }
  my $activity = selective_field_extract($d, [qw(id activity_type_id workout_id group_num set_num note visibility_type_id)]);
  $activity->{activity_result} = selective_field_extract($d, [$at->valid_fields]);
  #>>>

  return $activity;
}

sub selective_field_extract ($hash, $fields) {
  return {map {exists($hash->{$_}) ? ($_ => $hash->{$_}) : ()} $fields->@*};
}

sub effective_user ($self) {
  if (my $username = $self->validation->param('username')) {
    if (my $user = $self->model('User')->find({username => $username})) {return $user}
  }
  return $self->current_user;
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
  )->grouped;

  if ($self->validation->param('combine') // $args{combine} // true) {
    $rs = $rs->whole;
  } else {
    $rs = $rs->uncombined;
  }

  $rs = $rs->for_user($self->effective_user)->visible_to($self->current_user);

  if (my $workout_id = $self->validation->param('workoutID')) {
    my $workout = $self->model_find(Workout => $workout_id) or return $self->render_not_found('Workout');
    $rs = $rs->in_workout($workout);
  }
  if (defined($self->validation->param('activityTypeID'))) {
    my $activity_type_ids = $self->validation->every_param('activityTypeID');
    foreach my $activity_type_id ($activity_type_ids->@*) {
      $self->model_find(ActivityType => $activity_type_id) or return $self->render_not_found('ActivityType');
    }
    $rs = $rs->search({activity_type_id => {-in => $activity_type_ids}});
  }
  if (my $start_date = $self->validation->param('start')) {
    $rs = $rs->after_date($start_date);
  }
  if (my $end_date = $self->validation->param('end')) {
    $rs = $rs->before_date($end_date);
  }
  my $event_filter = $self->validation->param('event');
  if(defined($event_filter) ) {
    $rs = $rs->has_event($event_filter);
  }

  foreach my $distance_filter (($self->validation->every_param('distance')//[])->@*) {
    my ($value, $op) = $self->decode_distance_param($distance_filter);
    $rs = $rs->search({
      'normalized_distance.value' => {$op => $value}
    })
  }

  foreach my $time_filter (($self->validation->every_param('net_time')//[])->@*) {
    my ($value, $op) = $self->decode_time_param($time_filter);
    $rs = $rs->search({
      "activity_result.net_time" => {$op => $value}
    })
  }

  foreach my $time_filter (($self->validation->every_param('duration')//[])->@*) {
    my ($value, $op) = $self->decode_time_param($time_filter);
    $rs = $rs->search({
      "activity_result.duration" => {$op => $value}
    })
  }

  foreach my $time_filter (($self->validation->every_param('pace')//[])->@*) {
    my ($value, $op) = $self->decode_time_param($time_filter);
    $rs = $rs->search({
      "activity_result.pace" => {$op => $value}
    })
  }

  foreach my $speed_filter (($self->validation->every_param('speed')//[])->@*) {
    my ($value, $op) = $self->decode_distance_param($speed_filter, 'Rate');
    $rs = $rs->search({
      'activity_result.speed' => {$op => $value}
    })
  }

  return $rs;
}

sub decode_distance_param($self, $txt, $uom_type = 'Distance') {
  my $jv = JSON::Validator->new();
  $jv->schema({
    type => 'object',
    required => [qw(value uom_abbr op)],
    properties => {
      value => {type => 'number', minimum => 0},
      uom_abbr => {type => 'string'},
      op => {type => 'string', enum => [qw(= > >= < <=)]},
    }
  });
  my $f = decode_json($txt);
  if(my @errors = $jv->validate($f)) {
    die(@errors)
  }
  my $v = $f->{value};
  my $dist_uom_type = $self->model('UnitOfMeasureType')->find({description => $uom_type});
  my $unit = $self->model('UnitOfMeasure')->search({abbreviation => $f->{uom_abbr}, unit_of_measure_type_id => $dist_uom_type->id})->first;
  die("Invalid unit: " . $f->{uom_abbr}) unless($unit);
  $v *= $unit->normalization_factor if(defined($unit->normal_unit));
  return ($v, $f->{op})
}

sub decode_time_param($self, $txt) {
  my $jv = JSON::Validator->new();
  $jv->schema({
    type => 'object',
    required => ['value','op'],
    properties => {
      value => {type => 'string'},
      op => {type => 'string', enum => [qw(= > >= < <=)]}
    }
  });
  my $f = decode_json($txt);
  if(my @errors = $jv->validate($f)) {
    die(@errors);
  }
  die('/value: Does not match time format') unless($f->{value} =~ /^\d{1,}:\d{2}:\d{2}$/);
  return ($f->{value}, $f->{op});
}

sub custom_sort_for_column ($self, $col_name) {
  return 'normalized_distance.value'  if ($col_name eq 'distance');
  return 'activity_result.net_time'   if ($col_name eq 'time');
  return 'activity_result.pace'       if ($col_name eq 'pace');
  return 'activity_result.speed'      if ($col_name eq 'speed');
  return 'activity_result.start_time' if ($col_name eq 'startTime');
  return undef;
}

sub insert_record ($self, $data) {
  my $workout = $self->model('Workout')->find($data->{workout_id});
  $data->{group_num} = $workout->next_group_num                   if (!defined($data->{group_num}));
  $data->{set_num}   = $workout->next_set_num($data->{group_num}) if (!defined($data->{set_num}));
  return $self->SUPER::insert_record($data);
}

sub update_record ($self, $entity, $data) {
  foreach (qw(group_num set_num id workout_id)) {
    delete($data->{$_});
  }
  delete($data->{activity_result}->{id});
  $entity->activity_result->update(delete($data->{activity_result}));
  return $self->SUPER::update_record($entity, $data);
}

sub delete_record ($self, $entity) {
  $entity->activities->update({whole_activity_id => undef});
  $entity->user_event_activities->update({activity_id => undef});
  return $self->SUPER::delete_record($entity);
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
    my $ers = $self->resultset(combine => false)->before_date($end)->has_event;
    my $una = $self->effective_user->user_nominal_activities->search({year => defined($period) ? $start->year : undef});

    my @activity_summaries;
    foreach ($self->app->model('ActivityType')->all) {
      my $sl      = $ars->activity_type($_);
      my $sers = $ers->activity_type($_);
      my $nominal = $una->search({activity_type_id => $_->id})->first;
      my %nom;
      if (defined($nominal)) {
        my $pd = $nominal->per_day;
        %nom = (nominal => {(map {$_ => $pd->{$_} * $nominal->days_in_range_between_dates($start, $end, $sl->after_date($today->strftime('%F'))->count > 0)} keys($pd->%*))});
      }
      push(
        @activity_summaries, {
          activityTypeID => $_->id,
          distance       => $sl->total_distance,
          unitID         => $unit->id,
          eventDistance  => $sers->total_distance,
          %nom
        }
        )
        if ($sl->count || defined($nominal));
    }

    $today->add(days => 1) if($ars->after_date($today->strftime('%F'))->count > 0);
    return $self->render(
      openapi => {
        period => {
          daysElapsed => $start->delta_days($start > $today ? $start : min($end, $today))->delta_days,
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
  my $showEmpty     = $self->validation->param('includeEmpty') // false;

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
  my $activities = [];

  try {
    my $asset = $self->param('file')->asset->to_file;
    my $ug    = Data::UUID->new;
    $asset->move_to(File::Spec->join($self->app->conf->paths->tmp, $ug->to_string($ug->create)));

    my $ds = $self->model_find(ExternalDataSource => $self->param('externalDataSourceID'))
      or $self->render_not_found('ExternalDataSource');

    my $import_class = $ds->import_class;
    require(module_path($import_class));
    my $importer = $import_class->new(file => $asset->path);

    foreach my $id ($importer->get_activities()) {
      my $data = $importer->get_activity_data($id);
      my ($activity, $is_existing) = $self->import_activity($data, $self->current_user);
      push($activities->@*, {$self->encode_model($activity)->%*, isNew => !$is_existing});

      if (!$is_existing && $activity->activity_type->activity_context->has_map) {
        my $job_id = $self->app->minion->enqueue(
          import_activity_points => [$import_class, $asset->path, $data->{activity_id}, $activity->activity_result_id]);
        $self->app->minion->result_p($job_id)->then(sub ($info) {$self->_cleanup_files($asset->path)});
      }
    }

    $self->_cleanup_files($asset->path);

    return $self->render(openapi => $activities);
  } catch ($e) {
    return $self->render_error(HTTP_BAD_REQUEST, $e)
  }
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
    $self->app->minion->enqueue(copy_activity_points => [$activity->id, join($COMMA, map {$_->id} @to_merge)]);
    return $self->render(openapi => $self->encode_model($activity));
  } catch ($e) {
    return $self->render_error(HTTP_BAD_REQUEST, $e)
  }
}

sub _cleanup_files ($self, $path) {
  return unless (-e $path);
  my $jobs = $self->app->minion->jobs({tasks => ['import_activity_points'], states => [qw(active inactive)]});
  while (my $info = $jobs->next) {
    return if ($info->{args}->[1] eq $path);
  }
  unlink($path);
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

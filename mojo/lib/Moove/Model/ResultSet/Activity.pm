package Moove::Model::ResultSet::Activity;
use v5.36;

use Role::Tiny::With;
with 'Moove::Role::Merge::Activity', 'Moove::Role::Merge::ActivityResult';

use base qw(DBIx::Class::ResultSet);
use DateTime;
use DateTime::Duration;
use DateTime::Format::Duration;
use DateTime::Format::MySQL;
use List::Util qw(sum max min reduce);

use builtin      qw(true false);
use experimental qw(builtin);

use DCS::Constants qw(:symbols);

sub grouped ($self) {
  return $self->search(
    undef, {
      group_by => [qw(workout_id activity_type_id group_num)],
    }
  );
}

sub prior_import ($self, $id, $importer) {
  return $self->search(
    {
      'external_identifier'     => $id,
      'external_data_source_id' => $importer->id,
    }
  );
}

sub writable_by ($self, $user) {
  # TODO: Add admin pass here
  return $self->for_user($user);
}

sub for_user ($self, $user) {
  my $userID = defined($user) ? $user->id : -1;
  return $self->search(
    {
      'workout.user_id' => $userID
    }, {
      join => 'workout'
    }
  );
}

sub in_workout ($self, $workout) {
  return $self->search(
    {
      workout_id => $workout->id
    }
  );
}

sub visible_to ($self, $user) {
  return $self->search(
    {
      -or => [
        {'me.visibility_type_id' => 3},
        {'workout.user_id'       => $user->id},
        {
          -and => [{'me.visibility_type_id' => 2}, {'friendship_initiators.receiver_id' => $user->id}]
        }
      ]
    }, {
      join => {workout => {user => 'friendship_initiators'}}
    }
  );
}

sub for_person ($self, $person) {
  return $self->search(
    {
      'participants.person_id' => $person->id
    }, {
      join => {result => 'participants'}
    }
  );
}

sub whole ($self) {
  return $self->search(
    {
      'me.whole_activity_id' => undef
    }
  );
}

sub uncombined ($self) {
  return $self->search(
    {
      'me.id' => {
        -not_in => $self->result_source->schema->resultset('Activity')->search({whole_activity_id => {'<>' => undef}})
          ->get_column('whole_activity_id')->as_query
      }
    }
  );
}

sub whole_or_event ($self) {
  return $self->search(
    {
      '-or' => [{'event_id' => {'!=', undef}}, {'me.whole_activity_id' => undef}]
    }
  );
}

sub has_event ($self, $flag = true) {
  return $self->search(
    {
      'user_event_activities.id' => {($flag ? '<>' : '=') => undef}
    }, {
      join => 'user_event_activities'
    }
  );
}

sub core ($self) {
  return $self->search(
    {
      '-or' => [
        'activity_type.description' => 'Run',
        'activity_type.description' => 'Ride'
      ]
    }, {
      'join' => 'activity_type'
    }
  );
}

sub activity_type ($self, $type) {
  return $self->search(
    {
      'me.activity_type_id' => $type->id,
    }
  );
}

sub outdoor ($self) {
  return $self->search(
    {
      'activity_type.description' => {'!=' => 'Treadmill'}
    }, {
      'join' => 'activity_type'
    }
  );
}

sub year ($self, $year) {
  return $self->after_date("$year->01-01")->before_date("$year-12-31", true);
}

sub completed ($self) {
  return $self->search(
    {
      'me.activity_result_id' => {'<>' => undef}
    }, {
      join => 'activity_result'
    }
  );
}

sub ordered ($self, $direction = '-asc') {
  return $self->search(
    {},
    {
      join     => ['workout', 'activity_result'],
      order_by => {
        $direction => ['workout.date', 'activity_result.start_time']
      }
    }
  );
}

sub after_date ($self, $date, $inclusive = true) {
  return $self unless (defined($date));
  my $d  = ref($date) ? DateTime::Format::MySQL->format_datetime($date) : $date;
  my $op = $inclusive ? '>='                                            : '>';
  return $self->search(
    {
      'workout.date' => {$op => $d}
    }, {
      join => 'workout'
    }
  );
}

sub before_date ($self, $date, $inclusive = false) {
  return $self unless (defined($date));
  my $d  = ref($date) ? DateTime::Format::MySQL->format_datetime($date) : $date;
  my $op = $inclusive ? '<='                                            : '<';
  return $self->search(
    {
      'workout.date' => {$op => $d}
    }, {
      join => 'workout'
    }
  );
}

sub before_now($self) {
  return $self->search(
    {
      'workout.date' => {'<=' => DateTime::Format::MySQL->format_datetime(DateTime->now(time_zone => 'local')->truncate(to => 'day'))}
    }, {
      join => 'workout'
    }
  )
}

sub on_date($self, $date) {
  return $self unless(defined($date));
  my $d = ref($date) ? DateTime::Format::MySQL->format_datetime($date) : $date;
  return $self->search({
    'workout.date' => $d
  },{
    join => 'workout'
  })
}

sub has_distance ($self) {
  return $self->search({
    'base_activity_type.has_distance' => 'Y'
  }, {
    join => {activity_type => 'base_activity_type'}
  })
}

sub has_pace ($self) {
  return $self->search({
    'base_activity_type.has_pace' => 'Y'
  }, {
    join => {activity_type => 'base_activity_type'}
  })
}

sub has_speed ($self) {
  return $self->search({
    'base_activity_type.has_speed' => 'Y'
  }, {
    join => {activity_type => 'base_activity_type'}
  })
}

sub has_time ($self) {
  return $self->search({ 
    'base_activity_type.has_duration' => 'Y'
  }, {
    join => {activity_type => 'base_activity_type'}
  })
}

sub summary($self, $partition = undef) { # qw(activityType baseActivityType week month year)
  my $mk_ctx = sub($record) { return {} };

  my @grouping;
  if(!defined($partition)) {
    $mk_ctx = sub($record) { 
      return {
        activityTypes => [map +{id => $_}, split(/,/, $record->get_column('activity_type_ids'))],
        min_date => DateTime::Format::MySQL->parse_date($record->get_column('min_date') // '2000-01-01'),
        max_date   => DateTime::Format::MySQL->parse_date($record->get_column('max_date') // '3000-01-01'), 
        label     => 'All Activities',
      }
    };
  } elsif($partition eq 'activityType.all') {
    $mk_ctx = sub($record) { {
      activityTypes => [{ id => $record->get_column('activity_type_id')}],
      label => $record->get_column('activity_context_description') . ' ' . $record->get_column('base_activity_type_description') 
    }};
    @grouping = 'activity_type.id'
  } elsif($partition eq 'baseActivityType.base') {
    $mk_ctx = sub($record) { {
      activityTypes => [map +{id => $_}, $self->result_source->schema->resultset("BaseActivityType")->find($record->get_column('base_activity_type_id'))->activity_type_ids],
      label => $record->get_column('base_activity_type_description') 
    }};
    @grouping = 'base_activity_type.id'
  } elsif($partition eq 'time.week') {
    $mk_ctx = sub($record) {
      my $sd = DateTime::Format::MySQL->parse_date($record->get_column('min_date'))->truncate(to => 'local_week');
      return {
        activityTypes => [map +{id => $_}, split(/,/, $record->get_column('activity_type_ids'))],
        min_date => $sd,
        max_date => $sd->clone->add(days => 6),
        label => 'Week of ' . $sd->strftime("%F"),
    }};
    @grouping = (\['WEEK(activity_result.start_time)'], \['YEAR(activity_result.start_time)'])
  } elsif($partition eq 'time.month') {
    $mk_ctx = sub($record) {
      my $sd = DateTime::Format::MySQL->parse_date($record->get_column('min_date'))->truncate(to => 'month');
      return {
        activityTypes => [map +{id => $_}, split(/,/, $record->get_column('activity_type_ids'))],
        min_date => $sd,
        max_date => $sd->clone->add(months => 1)->subtract(days => 1),
        label => $sd->strftime("%b %Y"),
    }};
    @grouping = (\['MONTH(activity_result.start_time)'], \['YEAR(activity_result.start_time)'])
  } elsif($partition eq 'time.quarter') {
    $mk_ctx = sub($record) {
      my $sd = DateTime::Format::MySQL->parse_date($record->get_column('min_date'))->truncate(to => 'quarter');
      return {
        activityTypes => [map +{id => $_}, split(/,/, $record->get_column('activity_type_ids'))],
        min_date => $sd,
        max_date => $sd->clone->add(months => 3)->subtract(days => 1),
        label => $sd->strftime("%{quarter_abbr} %Y"),
    }};
    @grouping = (\['FLOOR((MONTH(activity_result.start_time)-1)/3)'], \['YEAR(activity_result.start_time)'])
  } elsif($partition eq 'time.year') {
    $mk_ctx = sub($record) {
      my $sd = DateTime::Format::MySQL->parse_date($record->get_column('min_date'))->truncate(to => 'year');
      return {
        activityTypes => [map +{id => $_}, split(/,/, $record->get_column('activity_type_ids'))],
        min_date => $sd,
        max_date => $sd->clone->add(years => 1)->subtract(days => 1),
        label => $sd->strftime("%Y"),
    }};
    @grouping = (\['YEAR(activity_result.start_time)'])
  } else {
    die("invalid partitioning");
  }

  my $rs = $self->search(undef, {
    join => [
      { activity_type => [qw(base_activity_type activity_context)]},
      { activity_result => 'normalized_distance' },
    ],
    select => [
      # Partitioning context
      {DATE => {MIN   => 'activity_result.start_time'}},
      {DATE => {MAX   => 'activity_result.start_time'}},
      \'GROUP_CONCAT(DISTINCT activity_type.id)',
      'activity_type.id',
      'base_activity_type.id',
      'base_activity_type.description',
      'activity_context.description',

      # Aggregate results
      ## counts
      {COUNT => 'me.id'},
      ## distance
      {SUM => 'normalized_distance.value'},
      {MAX => 'normalized_distance.value'},
      {MIN => 'normalized_distance.value'},
      {AVG => 'normalized_distance.value'},
      ## time
      {SUM => {TIME_TO_SEC => \'COALESCE(activity_result.net_time,activity_result.duration)'}},
      {MAX => {TIME_TO_SEC => \'COALESCE(activity_result.net_time,activity_result.duration)'}},
      {MIN => {TIME_TO_SEC => \'COALESCE(activity_result.net_time,activity_result.duration)'}},
      {AVG => {TIME_TO_SEC => \'COALESCE(activity_result.net_time,activity_result.duration)'}},
      {SUM => {TIME_TO_SEC => \'COALESCE(activity_result.duration,activity_result.net_time)'}},
      {MAX => {TIME_TO_SEC => \'COALESCE(activity_result.duration,activity_result.net_time)'}},
      {MIN => {TIME_TO_SEC => \'COALESCE(activity_result.duration,activity_result.net_time)'}},
      {AVG => {TIME_TO_SEC => \'COALESCE(activity_result.duration,activity_result.net_time)'}},
      # pace
      \'(SUM(TIME_TO_SEC(COALESCE(activity_result.net_time,activity_result.duration)))/60)/SUM(normalized_distance.value)',
      \'MIN(TIME_TO_SEC(activity_result.pace))/60',
      \'MAX(TIME_TO_SEC(activity_result.pace))/60',
      # speed
      \'SUM(normalized_distance.value)/(SUM(TIME_TO_SEC(COALESCE(activity_result.net_time,activity_result.duration)))/(60*60))',
      {MIN => 'activity_result.speed'},
      {MAX => 'activity_result.speed'},
    ],
    as => [qw(
      min_date
      max_date
      activity_type_ids
      activity_type_id
      base_activity_type_id
      base_activity_type_description
      activity_context_description
      counts_total
      distance_total
      distance_max
      distance_min
      distance_avg
      time_total
      time_max
      time_min
      time_avg
      duration_total
      duration_max
      duration_min
      duration_avg
      pace_avg
      pace_max
      pace_min
      speed_avg
      speed_min
      speed_max
    )],
    group_by => [ @grouping ],
  });
  my @summaries;
  while (my $summary = $rs->next) {
    push(@summaries, {
      ctx => $mk_ctx->($summary),
      counts => {
        total       => $summary->get_column('counts_total'),
        # maxPerDay => $self->max_activities_per('day'),
        # maxPerWeek => $self->max_activities_per('week'),
        # maxPerMonth => $self->max_activities_per('month'),
        # maxPerYear => $self->max_activities_per('year'),
      },
      distance => {
        total       => $summary->get_column('distance_total'),
        max         => $summary->get_column('distance_max'),
        min         => $summary->get_column('distance_min'),
        avg         => $summary->get_column('distance_avg'),
      },
      pace => {
        avg        => $summary->get_column('pace_avg'),
        min        => $summary->get_column('pace_min'),
        max        => $summary->get_column('pace_max'),
      },
      speed => {
        avg        => $summary->get_column('speed_avg'),
        min        => $summary->get_column('speed_min'),
        max        => $summary->get_column('speed_max'),
      },
      time => {
        net => {
          total    => $summary->get_column('time_total'),
          avg      => $summary->get_column('time_avg'),
          max      => $summary->get_column('time_max'),
          min      => $summary->get_column('time_min'),
        },
        duration => {
          total    => $summary->get_column('duration_total'),
          avg      => $summary->get_column('duration_avg'),
          max      => $summary->get_column('duration_max'),
          min      => $summary->get_column('duration_min'),
        }
      }
    })
  }
  return @summaries;
}

sub max_activities_per($self, $period = 'day') {
  my @grouping;
  if($period eq 'day') {
    @grouping = (\['DATE(activity_result.start_time)']);
  } elsif($period eq 'week') {
    @grouping = (\['YEAR(activity_result.start_time)'], \['WEEK(activity_result.start_time)'])
  } elsif($period eq 'month') {
    @grouping = (\['YEAR(activity_result.start_time)'], \['MONTH(activity_result.start_time)'])
  } elsif($period eq 'year') {
    @grouping = (\['YEAR(activity_result.start_time)'])
  }

  my $rs = $self->search(undef, { 
    select => 
      {count => 'me.id'}, 
    as => 
      [qw(count)], 
    group_by => 
      [ @grouping ], 
    order_by => 
      {-desc => \['COUNT(me.id)']} 
    }
  );
  my ($t) = $rs->all();
  return $t->get_column('count');
}

sub near_distance ($self, $d) {
  my $v      = $d->normalized_value;
  my $margin = $d->normalized_value * 0.05;

  return $self->search(
    {
      -and => [
        \['distance.value * uom.conversion_factor >= ?' => $v - $margin],
        \['distance.value * uom.conversion_factor <= ?' => $v + $margin]
      ]
    }, {
      join => {distance => 'uom'}
    }
  );
}

sub min_distance ($self, $d) {
  return $self->search(
    {
      -and => [\['distance.value * uom.conversion_factor >= ?' => $d->normalized_value],]
    }, {
      join => {distance => 'uom'}
    }
  );
}

sub max_distance ($self, $d) {
  return $self->search(
    {\['distance.value * uom.conversion_factor <= ?' => $d->normalized_value]},
    {
      join => {distance => 'uom'}
    }
  );
}

sub total_distance ($self) {
  my $v = sum(map {$_->distance->normalized_value} $self->related_resultset('activity_result')->with_distance->all) // 0;
  return $self->result_source->schema->resultset('Distance')->new_normal($v)
}

sub ordered_by_distance ($self) {
  return $self->search(undef,
    { 
      join => {activity_result => {distance => 'unit_of_measure'}},
      order_by => { '-asc' => \[ 'distance.value * unit_of_measure.normalization_factor' ] }
    }
  )
}

sub merge ($self, @activities) {
  die("At least two activities are required for merging") unless (@activities >= 2);

  my @merge         = sort {$a->start_time <=> $b->start_time} @activities;
  my @merge_results = grep {defined} map {$_->activity_result} @merge;
  my $workout       = $merge[0]->workout;
  my $activity_type = $merge[0]->activity_type;
  my $start_time    = $merge[0]->start_time;

  my $base = $activity_type->base_activity_type;
  die("Merging is valid only for distance-based activities")
    unless ($base->has_distance);
  die("Merged Activities must occur within one day of each other\n")
    if ($start_time->delta_days($merge[-1]->start_time)->delta_days > 1);
  for (my $i = 0 ; $i <= $#merge ; $i++) {
    die("Merged Activities must be in the same workout\n")
      unless ($workout->id == $merge[$i]->workout_id);
    die("Merged Activities must be of the same type\n")
      unless ($activity_type->id == $merge[$i]->activity_type_id);
    die("Cannot merge already-merged activities\n")
      if ($merge[$i]->whole_activity);
  }

  my $data = {
    activity_type_id   => $activity_type->id,
    workout_id         => $workout->id,
    note               => $self->merge_notes(@merge),
    group_num          => $self->merge_group_nums(@merge),
    set_num            => $self->merge_set_nums(@merge),
    visibility_type_id => $self->merge_visibility_types(@merge),
    created_at         => DateTime::Format::MySQL->format_datetime($self->merge_created_ats(@merge)),
    updated_at         => DateTime::Format::MySQL->format_datetime($self->merge_updated_ats(@merge)),
    activity_result    => {
      start_time  => $start_time,
      temperature => $self->merge_temperatures(@merge_results),
      heart_rate  => $self->merge_heart_rates(@merge_results),
    }
  };
  $data->{activity_result}->{duration} = $self->merge_durations(@merge_results) if ($base->has_duration);
  if ($base->has_distance) {
    my $distance = $self->merge_distances(@merge_results);
    $data->{activity_result}->{distance_id} = $self->result_source->schema->resultset('Distance')
      ->find_or_create_in_units($distance->{value}, $distance->{unit_of_measure})->id;
  }
  $data->{activity_result}->{net_time} = $self->merge_net_times(@merge_results)
    if ($base->has_distance && $base->has_duration);
  $data->{activity_result}->{pace}                   = $self->merge_paces(@merge_results)       if ($base->has_pace);
  $data->{activity_result}->{speed}                  = $self->merge_speeds(@merge_results)      if ($base->has_speed);
  $data->{activity_result}->{repetitions}            = $self->merge_repetitions(@merge_results) if ($base->has_repeats);
  $data->{activity_result}->{map_visibility_type_id} = $self->merge_map_visibility_types(@merge_results)
    if ($activity_type->activity_context->has_map);

  my $activity;
  $self->result_source->schema->txn_do(
    sub {
      $activity = $self->create($data);
      $_->update({whole_activity_id => $activity->id}) foreach (@merge);
    }
  );
  return $activity;
}

1;

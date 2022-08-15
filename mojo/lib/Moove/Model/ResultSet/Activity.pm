package Moove::Model::ResultSet::Activity;
use v5.36;

use Role::Tiny::With;
with 'Moove::Role::Unit::Conversion';
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
      'whole_activity_id' => undef
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
      '-or' => [{'event_id' => {'!=', undef}}, {'whole_activity_id' => undef}]
    }
  );
}

sub has_event ($self) {
  return $self->search(
    {
      'user_event_activities.id' => {'<>' => undef}
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
      activity_type_id => $type->id,
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
      activity_result_id => {'<>' => undef}
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
  return sum(map {$_->distance->normalized_value} $self->related_resultset('activity_result')->with_distance->all) // 0;
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

  # use Data::Printer;
  # p $data->{activity_result};
  # return {};

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

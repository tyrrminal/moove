package Moove::Model::ResultSet::Activity;
use v5.36;

use base qw(DBIx::Class::ResultSet);
use DateTime;
use DateTime::Duration;
use DateTime::Format::Duration;
use DateTime::Format::MySQL;
use List::Util qw(sum max min reduce);

use DCS::Constants qw(:symbols);

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
  return $self->after_date("$year->01-01")->before_date("$year-12-31");
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

sub after_date ($self, $date) {
  my $d = ref($date) ? DateTime::Format::MySQL->format_datetime($date) : $date;
  return $self->search(
    {
      'workout.date' => {'>=' => $d}
    }, {
      join => 'workout'
    }
  );
}

sub before_date ($self, $date) {
  my $d = ref($date) ? DateTime::Format::MySQL->format_datetime($date) : $date;
  return $self->search(
    {
      'workout.date' => {'<=' => $d}
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
  return sum(map {$_->activity_result->distance->normalized_value} $self->all) // 0;
}


sub merge ($self, @activities) {
  die("At least two activities are required for merging") unless (@activities >= 2);
  my @merge = sort {$a->start_time <=> $b->start_time} @activities;

  my $activity_type = $merge[0]->activity_type;
  my $start_time    = $merge[0]->start_time;

  for (my $i = 0 ; $i <= $#merge ; $i++) {
    die("Merged Activities must be in the same workout\n")
      unless ($merge[0]->workout_id == $merge[$i]->workout_id);
    die("Merged Activities must be of the same type\n")
      unless ($activity_type->id == $merge[$i]->activity_type_id);
    die("Cannot merge already-merged activities\n")
      if ($merge[$i]->whole_activity);
  }
  die("Merged Activities must occur within one day of each other\n")
    if ($start_time->delta_days($merge[-1]->start_time)->delta_days > 1);

  my $a_data = {
    activity_type_id   => $activity_type->id,
    note               => join($NEWLINE x 2, map {$_->note} grep {$_->note} @merge),
    workout_id         => $merge[0]->workout_id,
    group_num          => min(map {$_->group_num} @merge),
    set_num            => min(map {$_->set_num} @merge),
    visibility_type_id => max(map {$_->visibility_type_id} @merge),
    created_at         => DateTime::Format::MySQL->format_datetime(min(map {$_->created_at} @merge)),
    updated_at         => DateTime::Format::MySQL->format_datetime(DateTime->now),
  };
  my $ar_data = {
    start_time  => $start_time,
    duration    => $merge[-1]->end_time - $merge[0]->start_time,
    net_time    => DateTime::Duration->new(hours => 0, minutes => 0, seconds => 0),
    temperature => $self->average_temperature(@merge),
    heart_rate  => $self->average_hr(@merge),
  };

  my @merge_ar = grep {defined} map {$_->activity_result} @merge;
  my %units    = map  {$_->distance->unit_of_measure_id => 1} @merge_ar;
  $ar_data->{net_time} = reduce {$ar_data->{net_time->seconds}} @merge_ar;
  foreach my $ar (@merge_ar) {
    $ar_data->{net_time} = $ar_data->{net_time}->add($ar->net_time);
  }
  my $u = $self->result_source->schema->resultset('UnitOfMeasure')->find((keys(%units))[0]);

  my $d_data = {};
  if (keys(%units) > 1) {
    $ar_data->{distance}->{unit_of_measure_id} = $u->normalized_unit;
    $ar_data->{distance}->{value} =
      sum(map {$_->distance->normalized_value} grep {defined} map {$_->activity_result} @merge);
  } else {
    $ar_data->{distance}->{unit_of_measure_id} = $u;
    $ar_data->{distance}->{value} =
      sum(map {$_->distance->value} grep {defined} map {$_->activity_result} @merge);
  }
  $ar_data->{map_visibility_type_id} = max(map {$_->map_visibility_type_id} @merge_ar);

  use Data::Printer;
  p $ar_data;
  return {};

  my $activity;
  $self->result_source->schema->txn_do(
    sub {
      $activity = $self->create({$a_data->%*, activity_result => $ar_data});
      foreach (@merge) {
        $_->update({whole_activity_id => $activity->id});
      }
      foreach (@merge_ar) {
        foreach my $p ($_->activity_points) {
          $activity->add_to_activity_points({$p->timestamp, $p->location});
        }
      }
    }
  );
  return $activity;
}
1;

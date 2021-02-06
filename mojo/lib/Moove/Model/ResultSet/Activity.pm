package Moove::Model::ResultSet::Activity;
use base qw(DBIx::Class::ResultSet);

use DCS::Constants qw(:existence);

use experimental qw(signatures postderef);

sub prior_import ($self, $id, $importer) {
  return $self->search(
    {
      'external_identifier'     => $id,
      'external_data_source_id' => $importer->id,
    }
  );
}

sub for_user ($self, $user) {
  return $self->search(
    {
      'workout.user_id' => $user->id
    }, {
      join => 'workout'
    }
  );
}

sub in_workout ($self, $workout) {
  return $rs->search(
    {
      workout_id => $workout->id
    }
  );
}

sub visible_to ($self, $user) {
  return $self->search(
    {
      -or => [
        {visibility_type_id => 3},
        {'workout.user_id'  => $user->id},
        {
          -and => [{visibility_type_id => 2}, {'friendship_initiators.receiver_id' => $user->id}]
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

sub whole($self) {
  return $self->search(
    {
      'whole_activity_id' => $NULL
    }
  );
}

sub uncombined($self) {
  return $self->search(
    {
      'me.id' => {
        -not_in => $self->result_source->schema->resultset('Activity')->search({whole_activity_id => {'<>' => $NULL}})
          ->get_column('whole_activity_id')->as_query
      }
    }
  );
}

sub whole_or_event($self) {
  return $self->search(
    {
      '-or' => [{'event_id' => {'!=', $NULL}}, {'whole_activity_id' => $NULL}]
    }
  );
}

sub core($self) {
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

sub outdoor($self) {
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

sub completed($self) {
  return $self->search({}, {join => 'result'});
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

1;

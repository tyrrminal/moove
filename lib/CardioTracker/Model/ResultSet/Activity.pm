package CardioTracker::Model::ResultSet::Activity;
use base qw(DBIx::Class::ResultSet);

use Modern::Perl;

use DCS::Constants qw(:existence);

sub add_imported_activity {
  my $self = shift;
  my ($activity, $user) = @_;
  my $status = 'add';
  my $schema = $self->result_source->schema;

  my $activity_type = $schema->resultset('ActivityType')->find({ description => $activity->{type} });

  if(my $existing = $self->search(
      {
        'activity_references.reference_id'  => $activity->{activity_id},
        'activity_references.import_class ' => $activity->{importer}
      }, {
        join => 'activity_references'
      }
  )->first) {
    $status = 'skip';
    return wantarray ? ($existing,$status) : $existing;
  }
  my $act;
  my $event = $schema->resultset('Event')->for_user($user)->of_type($activity_type)->near_datetime($activity->{date}, 5, 30)->first;
  if($event && ($act = $event->activities->for_person($user->person->id)->first)) {
    $status = 'update';
    $act->update({
      user_id    => $user->id,
      start_time => $activity->{date},
      note       => $activity->{notes}
    });
    $act->result->update({heart_rate => $activity->{heart_rate}});
    $act->result->update({pace       => $activity->{pace}}) unless (defined($act->result->pace));
  } else {
    # Create the activity and result
    my $result = $schema->resultset('Result')->create(
      {
        gross_time => $activity->{gross_time},
        net_time   => $activity->{net_time},
        pace       => $activity->{pace},
        heart_rate => $activity->{heart_rate} || $NULL
      }
    );
    $act = $self->create(
      {
        user_id       => $user->id,
        activity_type => $activity_type,
        start_time    => $activity->{date},
        distance      => $schema->resultset('Distance')->find_or_create_from_miles($activity->{distance}),
        result        => $result,
        temperature   => $activity->{temperature},
        note          => $activity->{notes},
        event_id      => defined($event) ? $event->id : $NULL
      }
    );
    $schema->resultset('ActivityReference')->create(
      {
        activity     => $act,
        reference_id => $activity->{activity_id},
        import_class => $activity->{importer}
      }
    );
  }
  unless ($act->activity_points) {
    my @points = @{$activity->{activity_points}};
    foreach my $ap (@points) {
      my $loc = $self->app->model('Location')->create({
        latitude  => $ap->{lat},
        longitude => $ap->{lon}
      });
      $act->add_to_activity_points({
        location  => $loc,
        timestamp => $ap->{time}
      });
    }
  }
  return wantarray ? ($act,$status) : $act;
}

sub for_user {
  my $self = shift;
  my ($user) = @_;

  return $self->search(
    {
      'user_id' => $user->id
    }
  );
}

sub for_person {
  my $self = shift;
  my ($person) = @_;

  return $self->search({
    'participants.person_id' => $person->id
  },{
    join => { result => 'participants' }
  });
}

sub whole {
  my $self = shift;

  return $self->search({
    'whole_activity_id' => $NULL
  });
}

sub core {
  my $self = shift;

  return $self->search({
    '-or' => [
      'activity_type.description' => 'Run',
      'activity_type.description' => 'Ride'
    ]
  }, {
    'join' => 'activity_type'
  });
}

sub by_type {
  my $self = shift;
  my ($type) = @_;

  return $self->search({
    activity_type_id => $type->id,
  });
}

sub outdoor {
  my $self = shift;

  return $self->search(
    {
      'activity_type.description' => {'!=' => 'Treadmill'}
    }, {
      'join' => 'activity_type'
    }
    );
}

sub year {
  my $self = shift;
  my ($year) = @_;

  return $self->search(\['YEAR(start_time)=?', $year]);
}

sub completed {
  my $self = shift;

  return $self->search({}, {join => 'result'});
}

sub ordered {
  my $self = shift;
  my ($direction) = (@_, '-asc');

  return $self->search({}, {order_by => {$direction => 'me.start_time'}});
}

sub after_date {
  my $self = shift;
  my ($date) = @_;

  return $self->search({
    start_time => {'>=' => DateTime::Format::MySQL->format_datetime($date)}
  });
}

sub before_date {
  my $self = shift;
  my ($date) = @_;

  return $self->search({
    start_time => {'<=' => DateTime::Format::MySQL->format_datetime($date)}
  });
}

sub near_distance {
  my $self = shift;
  my ($d) = @_;

  my $v = $d->normalized_value;
  my $margin = $d->normalized_value * 0.05;

  return $self->search({
    -and => [
      \['distance.value * uom.conversion_factor >= ?' => $v-$margin],
      \['distance.value * uom.conversion_factor <= ?' => $v+$margin]
    ]
  },{
    join => { distance => 'uom' }
  })
}

sub min_distance {
  my $self = shift;
  my ($d) = @_;

  return $self->search({
    -and => [
      \['distance.value * uom.conversion_factor >= ?' => $d->normalized_value],
    ]
  },{
    join => { distance => 'uom' }
  })
}

sub max_distance {
  my $self = shift;
  my ($d) = @_;

  return $self->search({
    \['distance.value * uom.conversion_factor <= ?' => $d->normalized_value]
  },{
    join => { distance => 'uom' }
  })
}

1;

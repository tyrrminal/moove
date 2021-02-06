package Moove::Role::Import::Activity;
use Role::Tiny;

with 'Moove::Role::Unit::Conversion';

use boolean;
use DateTime;
use DateTime::Format::MySQL;
use DBIx::Class::InflateColumn::Time;

use DCS::Constants qw(:existence);

use experimental qw(signatures postderef);

sub import_activity ($self, $activity, $user, $workout = undef) {
  my $has_map = defined($activity->{activity_points});
  my $activity_type = $self->model('ActivityType')->lookup($activity->{type}, $has_map);

  my $data_source;
  if ($activity->{importer}) {
    $data_source = $self->app->model('ExternalDataSource')->find({name => $activity->{importer}});
    if (my $existing = $self->app->model('Activity')->prior_import($activity->{activity_id}, $data_source)->first) {
      return $existing;
    }
  }

  $workout = $self->app->model('Workout')->create(
    {
      user => $user,
      date => DateTime::Format::MySQL->format_date($activity->{date}),
      name => 'Imported ' . $activity_type->description
    }
    )
    unless (defined($workout));

  my $result_params = {
    start_time  => $activity->{date},
    weight      => $activity->{weight} || $NULL,
    heart_rate  => $activity->{heart_rate} || $NULL,
    temperature => $activity->{temperature},
  };
  if ($activity_type->base_activity_type->has_distance) {
    my $distance = $self->model('Distance')
      ->find_or_create_in_units($activity->{distance}, $self->model('UnitOfMeasure')->find({abbreviation => 'mi'}));
    $result_params->{distance} = $distance;
  }
  if ($activity_type->base_activity_type->has_duration) {
    $result_params->{duration} = $activity->{gross_time},;
  }
  if ($activity_type->base_activity_type->has_pace || $activity_type->base_activity_type->has_speed) {
    my $pace_units = $self->model('UnitOfMeasure')->find({abbreviation => '/mi'});
    $result_params->{net_time} = $activity->{net_time};
    $result_params->{pace} =
        $activity_type->base_activity_type->has_pace
      ? $activity->{pace}
      : $self->unit_conversion(value => $activity->{speed}, to => $pace_units);
    $result_params->{speed} = $activity_type->base_activity_type->has_speed ? $activity->{speed} : $self->unit_conversion(
      value => $self->time_to_minutes(DBIx::Class::InflateColumn::Time::_inflate($activity->{pace})),
      from  => $pace_units
    );
  }
  if ($activity_type->base_activity_type->has_repeats) {
    $result_params->{repetitions} = $activity->{repetitions};
  }
  my $result;
  if ($result = $self->find_matching_event_result($activity, $activity_type, $user)) {
    $result->update($result_params);
  } else {
    $result = $self->app->model('ActivityResult')->create($result_params);
  }

  my $act = $self->app->model('Activity')->create(
    {
      activity_type           => $activity_type,
      workout                 => $workout,
      group_num               => 1,
      set_num                 => 1,
      activity_result         => $result,
      note                    => $activity->{notes},
      external_data_source_id => (defined($data_source) ? $data_source->id : $NULL),
      external_identifier     => $activity->{activity_id},
    }
  );

  if ($activity_type->activity_context->has_map) {
    foreach my $ap ($activity->{activity_points}->@*) {
      my $loc = $self->app->model('Location')->create(
        {
          latitude  => $ap->{lat},
          longitude => $ap->{lon}
        }
      );
      $self->app->model('ActivityPoint')->create(
        {
          activity_result => $result,
          location        => $loc,
          timestamp       => $ap->{time}
        }
      );
    }
  }

  return $act;
}

sub find_matching_event_result ($self, $activity, $activity_type, $user) {
  my $between = [map {DateTime::Format::MySQL->format_datetime($activity->{date}->clone->add(minutes => $_))} (-30, 5)];

  my $uea = $self->app->model('UserEventActivity')->search(
    {
      'me.user_id'                     => $user->id,
      'event_type.activity_type_id'    => $activity_type->id,
      'event_activity.scheduled_start' => {-between => $between},
    }, {
      join => {event_registration => {event_activity => 'event_type'}}
    }
  )->first;
  return $NULL unless (defined($uea));

  return $uea->event_registration->event_participants->first->activity_result;
}

1;

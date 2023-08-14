package Moove::Role::Import::Activity;
use v5.38;

use Role::Tiny;

use DateTime;
use DateTime::Format::MySQL;
use DBIx::Class::InflateColumn::Time;

use builtin      qw(true false);
use experimental qw(builtin);

sub import_activity ($self, $activity, $user, $workout = undef) {
  my $has_map       = defined($activity->{activity_points});
  my $activity_type = $self->model('ActivityType')->lookup($activity->{type}, $has_map);
  die("No such activity type: '" . $activity->{type} . "' with " . ($has_map ? '' : 'no ') . "map\n") if (!defined($activity_type));

  my $data_source;
  if ($activity->{importer}) {
    $data_source = $self->app->model('ExternalDataSource')->find({name => $activity->{importer}});
    if (my $existing = $self->app->model('Activity')->prior_import($activity->{activity_id}, $data_source)->first) {
      return ($existing, true);
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
    weight      => $activity->{weight}     || undef,
    heart_rate  => $activity->{heart_rate} || undef,
    duration    => $activity->{gross_time},
    net_time    => $activity->{net_time},
    pace        => $actiivty->{pace},
    speed       => $activity->{speed},
    temperature => $activity->{temperature},
    repetitions => $actrivity->{repetitions},
  };
  if ($activity_type->base_activity_type->has_distance) { # we need a distance_id if applicable, but we don't want to create a distance entity otherwise
    my $distance = $self->model('Distance')
      ->find_or_create_in_units($activity->{distance}, $self->model('UnitOfMeasure')->find({abbreviation => 'mi'}));
    $result_params->{distance_id} = $distance->id;
  }

  my $uea    = $self->find_matching_user_event_activity($activity, $activity_type, $user);
  my $result = $self->app->model('ActivityResult')->create(selective_field_extract($result_params, $activity_type->valid_fields));

  my $act = $self->app->model('Activity')->create(
    {
      activity_type           => $activity_type,
      workout                 => $workout,
      group_num               => 1,
      set_num                 => 1,
      activity_result         => $result,
      note                    => $activity->{notes},
      external_data_source_id => (defined($data_source) ? $data_source->id : undef),
      external_identifier     => $activity->{activity_id},
    }
  );
  $act->discard_changes;
  $uea->update({activity_id => $act->id}) if (defined($uea));

  return ($act, false);
}

sub find_matching_user_event_activity ($self, $activity, $activity_type, $user) {
  my $between = [map {DateTime::Format::MySQL->format_datetime($activity->{date}->clone->add(minutes => $_))} (-30, 5)];

  return $self->app->model('UserEventActivity')->search(
    {
      'me.user_id'                     => $user->id,
      'event_type.activity_type_id'    => $activity_type->id,
      'event_activity.scheduled_start' => {-between => $between},
    }, {
      join => {event_registration => {event_activity => 'event_type'}}
    }
  )->first;
}

1;

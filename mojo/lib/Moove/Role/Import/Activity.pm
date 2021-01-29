package Moove::Role::Import::Activity;
use Role::Tiny;

use boolean;
use DateTime;
use DateTime::Format::MySQL;

use DCS::Constants qw(:existence);

use experimental qw(signatures postderef);

sub import_activity ($self, $activity, $user) {
  my $has_map       = defined($activity->{activity_points});
  my $activity_type = $self->model('ActivityType')->lookup($activity->{type}, $has_map);
  my $distance      = $self->model('Distance')
    ->find_or_create_in_units($activity->{distance}, $self->model('UnitOfMeasure')->find({abbreviation => 'mi'}));

  if ($activity->{importer}) {
    my $importer = $self->app->model('ExternalDataSource')->find({name => $activity->{importer}});
    if (my $existing = $self->app->model('Activity')->prior_import($activity->{activity_id}, $importer)->first) {
      return $existing;
    }
  }
  return;
  my $act;
  my $event = $self->app->model('Event')->for_user($user)->of_type($activity_type)->near_datetime($activity->{date}, 5, 30)->first;
  if ($event && ($act = $event->activities->for_person($user->person)->first)) {
    $act->update(
      {
        user_id     => $user->id,
        start_time  => $activity->{date},
        note        => $activity->{notes},
        distance    => $distance,
        temperature => $activity->{temperature},
        updated_at  => DateTime::Format::MySQL->format_datetime(DateTime->now),
      }
    );
    $act->result->update({heart_rate => $activity->{heart_rate}});
    $act->result->update({pace       => $activity->{pace}});
  } else {
    # Create the activity and result
    my $result = $self->app->model('Result')->create(
      {
        gross_time => $activity->{gross_time},
        net_time   => $activity->{net_time},
        pace       => $activity->{pace},
        heart_rate => $activity->{heart_rate} || $NULL
      }
    );
    $act = $self->app->model("Activity")->create(
      {
        user_id       => $user->id,
        activity_type => $activity_type,
        start_time    => $activity->{date},
        distance      => $distance,
        result        => $result,
        temperature   => $activity->{temperature},
        note          => $activity->{notes},
        event_id      => defined($event) ? $event->id : $NULL,
        created_at    => DateTime::Format::MySQL->format_datetime(DateTime->now),
      }
    );
    $self->app->model('ActivityReference')->create(
      {
        activity     => $act,
        reference_id => $activity->{activity_id},
        import_class => $activity->{importer}
      }
      )
      if ($activity->{importer});
  }
  if (!$act->activity_points->all && $activity->{activity_points}) {
    my @points = @{$activity->{activity_points}};
    foreach my $ap (@points) {
      my $loc = $self->app->model('Location')->create(
        {
          latitude  => $ap->{lat},
          longitude => $ap->{lon}
        }
      );
      $act->add_to_activity_points(
        {
          location  => $loc,
          timestamp => $ap->{time}
        }
      );
    }
  }
  $self->app->model('UserGoal')->for_user($act->user)->of_type($act->activity_type)->update_applicable_goals($act);
  return $act;
}


1;

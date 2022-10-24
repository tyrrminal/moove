package Moove::Controller::Role::ModelEncoding::Registration::EventActivity;
use v5.36;

use Role::Tiny;

use DateTime;

sub encode_model_eventactivity ($self, $entity) {
  return {
    id             => $entity->id,
    name           => $entity->name,
    event          => $self->encode_model($entity->event),
    entrants       => $entity->entrants,
    scheduledStart => $self->encode_datetime($entity->scheduled_start),
    eventType      => $self->encode_model($entity->event_type),
    distance       => $self->encode_model($entity->distance),
    results        => {
      url              => $entity->url,
      importable       => defined($entity->event->external_identifier) && $entity->scheduled_start < DateTime->now(),
      importCompletion => $self->get_task_progress($entity)
    }
  };
}

sub get_task_progress ($self, $event_activity) {
  my $jobs = $self->app->minion->jobs({states => ['active'], tasks => ['import_event_results']});
  while (my $job = $jobs->next) {
    next unless ($job->{args}->[0] == $event_activity->id);
    return $job->{notes}->{progress} // 0;
  }
  return 100 if ($event_activity->has_results);
  return undef;
}

1;

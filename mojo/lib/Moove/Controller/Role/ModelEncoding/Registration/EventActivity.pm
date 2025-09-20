package Moove::Controller::Role::ModelEncoding::Registration::EventActivity;
use v5.38;

use Role::Tiny;

use DateTime;
use Mojo::Util qw(class_to_path);

sub encode_model_eventactivity ($self, $entity) {
  my $importable = $entity->is_importable && $entity->scheduled_start < DateTime->now();
  my $fields     = [];
  if ($importable) {
    my $event = $entity->event;
    my $edc   = $event->external_data_source;
    my $class = $edc->import_class;
    require(class_to_path($class));
    $fields = $class->import_request_fields;
  }

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
      importable       => $self->encode_boolean($importable),
      importCompletion => $self->get_task_status($entity)->{progress} // 0,
      fields           => $fields,
    }
  };
}

sub get_task_status ($self, $event_activity) {
  my $jobs = $self->app->minion->jobs({states => ['inactive', 'active'], tasks => ['import_event_results']});
  while (my $job = $jobs->next) {
    next unless ($job->{args}->[0] == $event_activity->id);
    return $job->{notes};
  }
  return {progress => 100, status => 'completed'} if ($event_activity->has_results);
  return {progress => undef};
}

1;

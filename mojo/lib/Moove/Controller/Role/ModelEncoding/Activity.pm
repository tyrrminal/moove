package Moove::Controller::Role::ModelEncoding::Activity;
use Role::Tiny;

use experimental qw(signatures postderef);

sub encode_model_activity ($self, $entity) {
  return {
    id                 => $entity->id,
    activityType       => $entity->activity_type_id,
    note               => $entity->note,
    group              => $entity->group_num,
    set                => $entity->set_num,
    wholeActivityID    => $entity->whole_activity_id,
    externalDataSource => $entity->external_data_source_id,
    externalIdentifier => $entity->external_identifier,
    visibilityTypeID   => $entity->visibility_type_id,
    created_at         => $self->encode_datetime($entity->created_at),
    updated_at         => $self->encode_datetime($entity->updated_at),
    $self->encode_model_result($entity->activity_type, $entity->activity_result)->%*,
  };
}

sub encode_model_result ($self, $type, $entity) {
  my $base    = $type->base_activity_type;
  my $context = $type->activity_context;
  my $r       = {
    start_time  => $self->encode_datetime($entity->start_time),
    weight      => $entity->weight,
    heart_rate  => $entity->heart_rate,
    temperature => $entity->temperature,
  };
  if ($base->has_distance) {
    $r->{distance} = $self->encode_model($entity->distance);
  }
  if ($base->has_duration) {
    $r->{duration} = $self->encode_time($entity->duration);
  }
  if ($base->has_distance && $base->has_duration) {
    $r->{net_time} = $self->encode_time($entity->net_time);
    $r->{pace}     = $self->encode_time($entity->pace);
    $r->{speed}    = $entity->speed;
  }
  if ($base->has_repeats) {
    $r->{repetitions} = $entity->repetitions;
  }
  if ($context->has_map) {
    $r->{mapVisibilityTypeID} = $entity->map_visibility_type_id;
  }
  return $r;
}

1;

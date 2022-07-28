package Moove::Controller::Role::ModelEncoding::Activity;
use v5.36;

use Role::Tiny;

sub encode_model_activity ($self, $entity) {
  return {
    id                 => $entity->id,
    workoutID          => $entity->workout->id,
    activityTypeID     => $entity->activity_type_id,
    group              => $entity->group_num,
    wholeActivityID    => $entity->whole_activity_id,
    externalDataSource => $entity->external_data_source_id,
    externalIdentifier => $entity->external_identifier,
    visibilityTypeID   => $entity->visibility_type_id,
    createdAt          => $self->encode_datetime($entity->created_at),
    updatedAt          => $self->encode_datetime($entity->updated_at),
    sets               => [map { $self->encode_model_activity_set($_) } $entity->sets],
  };
}

sub encode_model_activity_set($self, $entity) {
  return {
    note               => $entity->note,
    set                => $entity->set_num,
    $self->encode_model_result($entity->activity_type, $entity->activity_result)->%*,
  }
}

sub encode_model_result ($self, $type, $entity) {
  my $base    = $type->base_activity_type;
  my $context = $type->activity_context;
  my $r       = {
    startTime   => $self->encode_datetime($entity->start_time),
    weight      => $entity->weight,
    heartRate   => $entity->heart_rate,
    temperature => $entity->temperature,
  };
  if ($base->has_distance) {
    $r->{distance} = $self->encode_value_with_units($entity->distance->value, $entity->distance->unit_of_measure);
  }
  if ($base->has_duration) {
    $r->{duration} = $self->encode_time($entity->duration);
  }
  if ($base->has_speed) {
    $r->{netTime} = $self->encode_time($entity->net_time);
    $r->{speed} =
      $self->encode_value_with_units($entity->speed, $self->model('UnitOfMeasure')->find({abbreviation => 'mph'}));
  }
  if ($base->has_pace) {
    $r->{netTime} = $self->encode_time($entity->net_time);
    $r->{pace}    = $self->encode_value_with_units($self->encode_time($entity->pace),
      $self->model('UnitOfMeasure')->find({abbreviation => '/mi'}));
  }
  if ($base->has_repeats) {
    $r->{repetitions} = $entity->repetitions;
  }
  if ($context->has_map) {
    $r->{mapVisibilityTypeID} = $entity->map_visibility_type_id;
  }
  return $r;
}

sub encode_value_with_units ($self, $value, $unit) {
  return {
    value           => $value,
    unitOfMeasureID => $unit->id,
  };
}

1;

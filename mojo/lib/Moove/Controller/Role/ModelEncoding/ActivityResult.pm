package Moove::Controller::Role::ModelEncoding::ActivityResult;
use v5.36;

use Role::Tiny;

sub encode_model_result ($self, $type, $entity) {
  my $base    = $type->base_activity_type;
  my $context = $type->activity_context;
  my $r       = {
    startTime   => $self->encode_datetime($entity->start_time),
    weight      => $entity->weight,
    heartRate   => $entity->heart_rate,
    temperature => $entity->temperature,
    hasMap      => $entity->has_map,
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
    if (defined($entity->pace)) {
      $r->{pace} = $self->encode_value_with_units($self->encode_time($entity->pace),
        $self->model('UnitOfMeasure')->find({abbreviation => '/mi'}));
    }
  }
  if ($base->has_repeats) {
    $r->{repetitions} = $entity->repetitions // 1;
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

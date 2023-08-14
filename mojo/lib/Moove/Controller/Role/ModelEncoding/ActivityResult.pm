package Moove::Controller::Role::ModelEncoding::ActivityResult;
use v5.38;

use Role::Tiny;

use Moove::Util::Unit::Conversion qw(unit_conversion time_to_minutes minutes_to_time);

sub encode_model_result ($self, $type, $entity) {
  my $uom     = $self->model('UnitOfMeasure');
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
  if (($base->has_speed || $base->has_pace) && (defined($entity->speed) || defined($entity->pace))) {
    $r->{netTime} = $self->encode_time($entity->net_time);
    $r->{speed}   = $self->encode_value_with_units($entity->speed // $entity->pace_to_speed,                    $uom->mph);
    $r->{pace}    = $self->encode_value_with_units($self->encode_time($entity->pace // $entity->speed_to_pace), $uom->per_mile);
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

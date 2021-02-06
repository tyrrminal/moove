package Moove::Controller::Role::ModelEncoding::Activity;
use Role::Tiny;

use experimental qw(signatures postderef);

sub encode_model_activity ($self, $entity) {
  return {
    id                 => $entity->id,
    activityTypeID     => $entity->activity_type_id,
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
    $r->{distance} = $self->encode_value_with_units($entity->distance->value, $entity->distance->unit_of_measure);
  }
  if ($base->has_duration) {
    $r->{duration} = $self->encode_time($entity->duration);
  }
  if ($base->has_speed) {
    $r->{net_time} = $self->encode_time($entity->net_time);
    $r->{speed} =
      $self->encode_value_with_units($entity->speed, $self->model('UnitOfMeasure')->find({abbreviation => 'mph'}));
  }
  if ($base->has_pace) {
    $r->{net_time} = $self->encode_time($entity->net_time);
    $r->{pace}     = $self->encode_value_with_units($self->encode_time($entity->pace),
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

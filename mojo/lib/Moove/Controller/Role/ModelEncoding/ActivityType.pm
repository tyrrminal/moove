package Moove::Controller::Role::ModelEncoding::ActivityType;
use v5.38;

use Role::Tiny;

use Mojo::JSON;

use builtin      qw(true false);
use experimental qw(builtin);

sub encode_model_activitytype ($self, $entity) {
  return {
    id          => $entity->id,
    description => $entity->description,
    hasRepeats  => $self->encode_boolean($entity->base_activity_type->has_repeats),
    hasDistance => $self->encode_boolean($entity->base_activity_type->has_distance),
    hasDuration => $self->encode_boolean($entity->base_activity_type->has_duration),
    hasPace     => $self->encode_boolean($entity->base_activity_type->has_pace),
    hasSpeed    => $self->encode_boolean($entity->base_activity_type->has_speed),
    hasMap      => $self->encode_boolean($entity->activity_context ? $entity->activity_context->has_map : 0),
    labels      => {
      base    => $entity->base_activity_type->description,
      context => (defined($entity->activity_context) ? $entity->activity_context->description : undef),
    }
  };
}

sub encode_boolean ($self, $value) {
  return $value ? true : false;
}

1;

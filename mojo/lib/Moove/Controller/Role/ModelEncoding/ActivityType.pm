package Moove::Controller::Role::ModelEncoding::ActivityType;
use Role::Tiny;

use Mojo::JSON;

use experimental qw(signatures postderef);

sub encode_model_activitytype ($self, $entity) {
  return {
    id           => $entity->id,
    description  => $entity->description,
    has_repeats  => $self->encode_boolean($entity->base_activity_type->has_repeats),
    has_distance => $self->encode_boolean($entity->base_activity_type->has_distance),
    has_duration => $self->encode_boolean($entity->base_activity_type->has_duration),
    has_map      => $self->encode_boolean($entity->activity_context ? $entity->activity_context->has_map : 0),
  };
}

sub encode_boolean ($self, $value) {
  return $value ? Mojo::JSON->true : Mojo::JSON->false;
}

1;

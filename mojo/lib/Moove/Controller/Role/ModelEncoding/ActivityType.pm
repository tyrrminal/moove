package Moove::Controller::Role::ModelEncoding::ActivityType;
use Role::Tiny;

use boolean;

use experimental qw(signatures postderef);

sub encode_model_activitytype ($self, $entity) {
  return {
    id           => $entity->id,
    description  => $entity->description,
    has_repeats  => !!$entity->base_activity_type->has_repeats,
    has_distance => !!$entity->base_activity_type->has_distance,
    has_duration => !!$entity->base_activity_type->has_duration,
    has_map      => !!(($entity->activity_context) ? $entity->activity_context->has_map : 0),
  };
}

1;

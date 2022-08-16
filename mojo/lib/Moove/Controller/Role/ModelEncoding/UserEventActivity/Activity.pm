package Moove::Controller::Role::ModelEncoding::UserEventActivity::Activity;
use v5.36;

use Role::Tiny;
with 'Moove::Controller::Role::ModelEncoding::ActivityResult';

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
    note               => $entity->note,
    set                => $entity->set_num,
    $self->encode_model_result($entity->activity_type, $entity->activity_result)->%*,
  };
}

1;
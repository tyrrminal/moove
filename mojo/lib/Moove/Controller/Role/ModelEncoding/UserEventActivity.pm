package Moove::Controller::Role::ModelEncoding::UserEventActivity;
use Role::Tiny;

use experimental qw(signatures postderef);

sub encode_model_usereventactivity ($self, $entity) {
  my $reg         = $entity->event_registration;
  my $participant = $reg->event_participants->first;
  my $ea          = $reg->event_activity;
  my $event       = $ea->event;

  my $r = {
    id                  => $entity->id,
    eventActivity       => $self->encode_model($ea),
    registration_number => $reg->registration_number,
    fee                 => $entity->registration_fee,
    date_registered     => $self->encode_date($entity->date_registered),
    visibilityTypeID    => $entity->visibility_type_id,
  };
  $r->{activity}   = $self->encode_model($entity->activity) if (defined($entity->activity));
  $r->{placements} = $self->encode_model([$participant->event_placements->all])
    if (defined($participant) && $participant->event_placements->count);
  return $r;
}

1;

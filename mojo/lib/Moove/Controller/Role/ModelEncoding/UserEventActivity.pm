package Moove::Controller::Role::ModelEncoding::UserEventActivity;
use Role::Tiny;

use experimental qw(signatures postderef);

sub encode_model_usereventactivity($self, $entity) {
  my $reg = $entity->event_registration;
  my $ea = $reg->event_activity;
  my $event = $ea->event;

  return {
    id => $entity->id,
    eventActivity => $self->encode_model($ea),
    defined($entity->activity) ? (activity => $self->encode_model($entity->activity)) : (),
    registration_number => $reg->registration_number,
    fee => $entity->registration_fee,
    date_registered => $self->encode_date($entity->date_registered),
  }
}

1;

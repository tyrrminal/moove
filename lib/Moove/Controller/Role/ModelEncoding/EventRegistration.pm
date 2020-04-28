package Moove::Controller::Role::ModelEncoding::EventRegistration;
use Role::Tiny;

use experimental qw(signatures);

sub render_model_eventregistration ($self, $er) {
  return {
    event        => $self->render_model($er->event),
    registration => {
      user     => $self->render_model($er->user),
      isPublic => $self->render_boolean($er->is_public),
    },
  };
}

1;

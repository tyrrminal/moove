package DCS::API::Role::Rest::Update;
use Role::Tiny;
use Role::Tiny::With;

use English qw(-no_match_vars);
use HTTP::Status qw(:constants);
use DCS::Constants qw(:boolean);

with 'DCS::API::Role::ModelEntity';

use experimental qw(signatures);

sub perform_update ($self, $entity, $data) {
  $entity->update($data);
}

sub update_authorized ($self, $entity) {
  return $TRUE;
}

sub update($self) {
  return unless ($self->openapi->valid_input);

  if (my $entity = $self->entity) {
    return $self->render_not_authorized unless ($self->update_authorized($entity));

    my $data = $self->req->json;
    delete($data->{id});

    try {
      $self->perform_update($entity, $self->decode_model($data));
      return $self->render(openapi => $self->render_model($entity));
    }
    catch {
      return $self->render_error(HTTP_BAD_REQUEST, $EVAL_ERROR->{msg});
    }
  }
  return $self->render_not_found($self->model_name);
}

1;

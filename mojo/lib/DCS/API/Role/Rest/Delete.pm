package DCS::API::Role::Rest::Delete;
use Role::Tiny;
use Role::Tiny::With;

with 'DCS::API::Role::ModelEntity';

use Syntax::Keyword::Try;
use English qw(-no_match_vars);
use HTTP::Status qw(:constants);
use DCS::Constants qw(:boolean);

use experimental qw(signatures);

sub perform_delete ($self, $entity) {
  $entity->delete;
}

sub delete_authorized ($self, $entity) {
  return $TRUE;
}

sub delete($self) {
  return unless ($self->openapi->valid_input);

  if (my $entity = $self->entity) {
    return $self->render_not_authorized unless ($self->delete_authorized($entity));
    try {
      $self->perform_delete($entity);
      return $self->render_no_content;
    }
    catch {
      return $self->render_error(HTTP_BAD_REQUEST, $EVAL_ERROR->{msg});
    }
  }
  return $self->render_not_found($self->model_name);
}

1;

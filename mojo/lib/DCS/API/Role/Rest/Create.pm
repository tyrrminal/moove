package DCS::API::Role::Rest::Create;
use Role::Tiny;

use English qw(-no_match_vars);
use HTTP::Status qw(:constants);
use DCS::Constants qw(:boolean);

use Syntax::Keyword::Try;
use experimental qw(signatures);

sub perform_create ($self, $data) {
  return $self->resultset->create($data);
}

sub create_authorized ($self, $data) {
  return $TRUE;
}

sub create($self) {
  return unless ($self->openapi->valid_input);

  my $data = $self->req->json;
  delete($data->{id});

  return $self->render_not_authorized unless ($self->create_authorized($data));
  try {
    my $entity = $self->perform_create($self->decode_model($data));
    return $self->render(openapi => $self->render_model($entity));
  }
  catch {
    return $self->render_error(HTTP_BAD_REQUEST, $EVAL_ERROR->{msg});
  }
}

1;

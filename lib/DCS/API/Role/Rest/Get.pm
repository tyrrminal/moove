package DCS::API::Role::Rest::Get;
use Role::Tiny;
use Role::Tiny::With;

with 'DCS::API::Role::ModelEntity';

use experimental qw(signatures);

sub get($self) {
  return unless ($self->openapi->valid_input);

  if (my $entity = $self->entity) {
    return $self->render(openapi => $self->render_model($entity));
  }
  return $self->render_not_found($self->model_name);
}

1;

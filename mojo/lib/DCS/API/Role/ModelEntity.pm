package DCS::API::Role::ModelEntity;
use Role::Tiny;

use experimental qw(signatures);

sub entity($self) {
  return $self->resultset->find($self->validation->param(lc($self->model_name) . 'ID'));
}

1;

package DCS::API::Role::Rest::List;
use Role::Tiny;

use experimental qw(signatures);

sub list($self) {
  return unless ($self->openapi->valid_input);

  return $self->render_paginated_list($self->resultset);
}

1;

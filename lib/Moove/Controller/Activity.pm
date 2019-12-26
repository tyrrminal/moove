package Moove::Controller::Exercise;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use DCS::Constants qw(:boolean);

sub get($self) {
  my $c = $self->openapi->valid_input or return;

  return $c->render(openapi => {});
}

1;

package Moove::Controller::Workout;
use Mojo::Base 'DCS::Base::API::Model::Controller';

use Role::Tiny::With;
with 'DCS::API::Role::Rest::Collection';
with 'Moove::Controller::Role::ModelEncoding::Workout';

use boolean;
use List::Util qw(sum min max);

use experimental qw(signatures postderef);

sub resultset ($self, @args) {
  my $rs = $self->SUPER::resultset(@args);

  if (my $start_date = $self->validation->param('start')) {
    $rs = $rs->after_date($start_date);
  }
  if (my $end_date = $self->validation->param('end')) {
    $rs = $rs->before_date($end_date);
  }

  return $rs;
}

1;

package Moove::Controller::Event;
use Mojo::Base 'DCS::Base::API::Model::Controller';
use Role::Tiny::With;

with 'DCS::API::Role::Rest::List', 'DCS::API::Role::Rest::Get';
with 'Moove::Controller::Role::ModelEncoding::Event','Moove::Controller::Role::ModelEncoding::EventActivity';
with 'Moove::Controller::Role::ModelEncoding::Default';

use experimental qw(signatures);

sub resultset ($self, @args) {
  my $rs = $self->SUPER::resultset(@args);
  if (my $start = $self->validation->param('start')) {
    $rs = $rs->on_or_after($self->parse_api_date($start))
  }
  if (my $end = $self->validation->param('end')) {
    $rs = $rs->on_or_before($self->parse_api_date($end))
  }
  if (my $name = $self->validation->param('name')) {
    $rs = $rs->by_name($name);
  }
  return $rs;
}

1;

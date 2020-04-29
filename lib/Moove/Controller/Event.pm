package Moove::Controller::Event;
use Mojo::Base 'DCS::API::Base::ModelController';
use Role::Tiny::With;

with 'DCS::API::Role::Rest::List';
with 'Moove::Controller::Role::ModelEncoding::Event';
with 'Moove::Controller::Role::ModelEncoding::Default';

use DCS::Constants qw(:boolean);

use experimental qw(signatures);

sub resultset($self) {
  my $rs = $self->SUPER::resultset();
  if (my $start = $self->validation->param('start')) {
    $rs = $rs->search({scheduled_start => {'>=' => $start}});
  }
  if (my $end = $self->validation->param('end')) {
    $rs = $rs->search({scheduled_start => {'<=' => $end}});
  }
  if (my $name = $self->validation->param('name')) {
    $rs = $rs->search({'event_group.name' => {-like => "%$name%"}}, {join => 'event_group'});
  }
  return $rs;
}

1;

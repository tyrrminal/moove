package Moove::Controller::Event;
use v5.36;

use Mojo::Base 'DCS::Base::API::Model::Controller';
use Role::Tiny::With;

with 'DCS::Base::Role::Rest::Collection',             'DCS::Base::Role::Rest::Entity';
with 'Moove::Controller::Role::ModelEncoding::Event', 'Moove::Controller::Role::ModelEncoding::EventActivity';
with 'Moove::Controller::Role::ModelEncoding::Default';

use DCS::Util::NameConversion qw(camel_to_snake convert_hash_keys);

sub decode_model ($self, $data) {
  delete($data->{id});
  $data = {convert_hash_keys($data->%*, \&camel_to_snake)};
  if (exists($data->{address}) && exists($data->{address}->{id})) {
    $data->{address_id} = $data->{address}->{id};
    delete($data->{address});
  }
  if (exists($data->{event_group}->{id})) {
    $data->{event_group_id} = $data->{event_group}->{id};
    delete($data->{event_group});
  }
  delete($data->{external_identifier}) unless ($data->{external_identifier});
  delete($data->{url})                 unless ($data->{url});
  return $data;
}

sub resultset ($self, @args) {
  my $rs = $self->SUPER::resultset(@args);
  if (my $start = $self->validation->param('start')) {
    $rs = $rs->on_or_after($self->parse_api_date($start));
  }
  if (my $end = $self->validation->param('end')) {
    $rs = $rs->on_or_before($self->parse_api_date($end));
  }
  if (my $name = $self->validation->param('name')) {
    $rs = $rs->by_name($name);
  }
  return $rs;
}

1;
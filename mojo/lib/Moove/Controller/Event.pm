package Moove::Controller::Event;
use v5.38;

use Mojo::Base 'DCS::Base::API::Model::Controller';
use Role::Tiny::With;

use Mojo::JSON qw(encode_json);

with 'DCS::Base::Role::Rest::Collection', 'DCS::Base::Role::Rest::Entity';
with 'Moove::Controller::Role::ModelEncoding::Event', 'Moove::Controller::Role::ModelEncoding::EventActivity',
  'Moove::Controller::Role::ModelEncoding::Distance';
with 'Moove::Controller::Role::ModelEncoding::Default';

use DCS::Util::NameConversion qw(camel_to_snake convert_hash_keys);

sub decode_model ($self, $data) {
  delete($data->{id});
  $data = {convert_hash_keys($data->%*, \&camel_to_snake)};
  if (exists($data->{address}) && exists($data->{address}->{id})) {
    if (defined($data->{address}->{id})) {
      $data->{address_id} = $data->{address}->{id};
    } else {
      $data->{address_id} = $self->app->model('Address')->get_address()->id;
    }
    delete($data->{address});
  }
  if (exists($data->{event_group}->{id})) {
    $data->{event_group_id} = $data->{event_group}->{id};
    delete($data->{event_group});
  } else {
    $data->{event_group}->{name} = $data->{name};
    $data->{event_group}->{url}  = $data->{url};
  }
  $data->{url}               = undef if (exists($data->{url}) && !$data->{url});
  $data->{import_parameters} = encode_json($data->{import_parameters});
  return $data;
}

sub insert_record ($self, $data) {
  my $event_series = delete($data->{event_series});
  my $entity       = $self->SUPER::insert_record($data);
  foreach my $series (($event_series // [])->@*) {
    $entity->add_to_event_series_events(
      {
        event_series_id => $series->{id}
      }
    );
  }
  return $entity;
}

sub update_record ($self, $entity, $data) {
  $entity->event_series_events->delete();
  foreach my $series ((delete($data->{event_series}) // [])->@*) {
    $entity->add_to_event_series_events(
      {
        event_series_id => $series->{id}
      }
    );
  }
  return $self->SUPER::update_record($entity, $data);
}

sub delete_record ($self, $entity) {
  $entity->event_series_events->delete();
  $self->SUPER::delete_record($entity);
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

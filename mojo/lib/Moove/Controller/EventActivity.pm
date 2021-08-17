package Moove::Controller::EventActivity;
use Mojo::Base 'DCS::Base::API::Model::Controller';
use Role::Tiny::With;

with 'DCS::Base::Role::Rest::Create', 'DCS::Base::Role::Rest::Update', 'DCS::Base::Role::Rest::Delete';
with 'Moove::Controller::Role::ModelEncoding::Event', 'Moove::Controller::Role::ModelEncoding::EventActivity';
with 'Moove::Controller::Role::ModelEncoding::Default';

use DCS::Util::NameConversion qw(camel_to_snake convert_hash_keys);

use experimental qw(signatures postderef);

sub resultset ($self) {
  my $rs = $self->SUPER::resultset();
  return $rs;
}

sub import_results ($self) {
  return $self->render(openapi => {});
}

sub delete_results ($self) {
  return $self->render(openapi => {});
}

sub decode_model ($self, $data) {
  delete($data->{id});
  $data = {convert_hash_keys($data->%*, \&camel_to_snake)};
  my $event = $self->model_find(Event => $self->validation->param('eventID')) or $self->render_not_found('Event');
  $data->{event_id} = $event->id;
  my $event_type = delete($data->{event_type});
  $data->{event_type_id} = $event_type->{id};
  my $distance = delete($data->{distance});
  $data->{distance_id} = $self->model('Distance')
    ->find_or_create_in_units($distance->{value}, $self->model('UnitOfMeasure')->find($distance->{unit_of_measure_id}))->id;
  return $data;
}

1;

package Moove::Controller::EventActivity;
use v5.38;

use Mojo::Base 'DCS::Base::API::Model::Controller';
use Role::Tiny::With;

use Mojo::JSON qw(encode_json);

with 'DCS::Base::Role::Rest::Get', 'DCS::Base::Role::Rest::Create', 'DCS::Base::Role::Rest::Update',
  'DCS::Base::Role::Rest::Delete';
with 'Moove::Controller::Role::ModelEncoding::EventGroup', 'Moove::Controller::Role::ModelEncoding::Registration::Event',
  'Moove::Controller::Role::ModelEncoding::Registration::EventActivity';
with 'Moove::Controller::Role::ModelEncoding::Default';

use DCS::Util::NameConversion qw(camel_to_snake convert_hash_keys);

use HTTP::Status qw(:constants);

sub encode_model_eventtype ($self, $entity) {
  return {id => $entity->id};
}

sub resultset ($self) {
  my $rs = $self->SUPER::resultset();
  return $rs;
}

sub import_results ($self) {
  return unless ($self->openapi->valid_input);

  my $event_activity = $self->entity;
  return $self->render_error(HTTP_BAD_REQUEST, "Event Activity is not importable",
    map {"$_"} $event_activity->import_validation_errors)
    if (!$event_activity->is_importable);
  $self->app->minion->enqueue(import_event_results => [$event_activity->id, $self->req->json->{importFields} // {}]);

  return $self->render(openapi => $self->encode_model($event_activity->event));
}

sub result_import_status ($self) {
  return unless ($self->openapi->valid_input);

  my $status = $self->get_task_status($self->entity);
  return $self->render(
    openapi => {
      importCompletion => $status->{progress} // 0,
      importStatus     => $status->{status}   // 'pending',
      (defined($status->{message}) ? (message => $status->{message}) : ()),
    }
  );
}

sub delete_results ($self) {
  return unless ($self->openapi->valid_input);

  $self->entity->delete_results;

  return $self->render_no_content;
}

sub decode_model ($self, $data) {
  delete($data->{id});
  $data = {convert_hash_keys($data->%*, \&camel_to_snake)};
  if (my $id = $self->validation->param('eventID')) {
    my $event = $self->model_find(Event => $id) or die("Event $id not found");
    $data->{event_id} = $event->id;
  } elsif ($id = $self->validation->param('eventActivityID')) {
    my $ea = $self->model_find(EventActivity => $id) or die("Event Activity $id not found");
    $data->{event_id} = $ea->event->id;
  }
  my $event_type = delete($data->{event_type});
  $data->{event_type_id} = $event_type->{id};
  my $distance = delete($data->{distance});
  $data->{distance_id} = $self->model('Distance')
    ->find_or_create_in_units($distance->{value}, $self->model('UnitOfMeasure')->find($distance->{unit_of_measure_id}))->id;
  $data->{import_parameters} = encode_json($data->{import_parameters});
  return $data;
}

1;

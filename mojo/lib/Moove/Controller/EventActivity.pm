package Moove::Controller::EventActivity;
use v5.36;

use Mojo::Base 'DCS::Base::API::Model::Controller';
use Role::Tiny::With;

with 'DCS::Base::Role::Rest::Get', 'DCS::Base::Role::Rest::Create', 'DCS::Base::Role::Rest::Update',
  'DCS::Base::Role::Rest::Delete';
with 'Moove::Controller::Role::ModelEncoding::Registration::Event',
  'Moove::Controller::Role::ModelEncoding::Registration::EventActivity';
with 'Moove::Controller::Role::ModelEncoding::Default';

use Mojo::Util qw(class_to_path);

use DCS::Util::NameConversion qw(camel_to_snake convert_hash_keys);

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
  my $event          = $event_activity->event;
  my $edc            = $event->external_data_source;
  my $class          = $edc->import_class;
  require(class_to_path($class));
  my $importer = $class->new(event_id => $event->external_identifier, race_id => $event_activity->external_identifier);

  my $edc_overrides = $self->app->conf->import_overrides->event_results->{$edc->name};
  my $overrides     = $edc_overrides ? $edc_overrides->{$event_activity->qualified_external_identifier} : {};

  $event_activity->update({entrants => $importer->total_entrants});
  foreach my $p ($importer->results->@*) {
    $self->process_overrides($overrides, $p);
    $event_activity->add_participant($p);
  }
  $event_activity->update_missing_result_paces;

  return $self->render(openapi => $self->encode_model($event_activity->event));
}

sub delete_results ($self) {
  return unless ($self->openapi->valid_input);

  my $event_activity = $self->entity;
  $event_activity->event_placement_partitions->related_resultset('event_placements')->delete();
  $event_activity->event_placement_partitions->delete();
  $event_activity->event_registrations->related_resultset('event_participants')->delete();
  $event_activity->event_registrations->without_user_activity->delete();

  return $self->render_no_content;
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

sub process_overrides ($self, $overrides, $record) {
  foreach my $key (keys($overrides->%*)) {
    my $replacements = $overrides->{$key};
    foreach my $v (keys($replacements->%*)) {
      $record->{$key} = $replacements->{$v} if ($record->{$key} eq $v);
    }
  }
}

1;

package Moove::Controller::EventGroup;
use v5.36;

use Mojo::Base 'DCS::Base::API::Model::Controller';
use Role::Tiny::With;

with 'DCS::Base::Role::Rest::Get';
with 'Moove::Controller::Role::ModelEncoding::UserEventActivity',
  'Moove::Controller::Role::ModelEncoding::UserEventActivity::Activity',
  'Moove::Controller::Role::ModelEncoding::ActivityType',
  'Moove::Controller::Role::ModelEncoding::EventPlacement',
  'Moove::Controller::Role::ModelEncoding::EventType',
  'Moove::Controller::Role::ModelEncoding::Registration::EventActivity';

sub encode_model_event ($self, $event) {
  return {
    id      => $event->id,
    name    => $event->name,
    year    => $event->year,
    address => $self->encode_model($event->address),
  };
}

sub encode_model_eventgroup ($self, $entity) {
  my $user = $self->current_user;
  if (my $username = $self->validation->param('username')) {
    $user = $self->model('User')->find({username => $username});
  }

  return {
    id     => $entity->id,
    name   => $entity->name,
    year   => $entity->year,
    url    => $entity->url,
    events => $self->encode_model([$entity->series_user_event_activities->for_user($user)->visible_to($self->current_user)->all])
  };
}

1;

package Moove::Controller::EventGroup;
use v5.38;

use Mojo::Base 'DCS::Base::API::Model::Controller';
use Role::Tiny::With;

with qw(DCS::Base::Role::Rest::List DCS::Base::Role::Rest::Create DCS::Base::Role::Rest::Entity);
with 'Moove::Controller::Role::ModelEncoding::UserEventActivity',
  'Moove::Controller::Role::ModelEncoding::UserEventActivity::Activity',
  'Moove::Controller::Role::ModelEncoding::ActivityType',
  'Moove::Controller::Role::ModelEncoding::EventPlacement',
  'Moove::Controller::Role::ModelEncoding::EventType',
  'Moove::Controller::Role::ModelEncoding::Registration::EventActivity';

sub decode_model ($self, $data) {
  my $type = delete($data->{type});
  $data->{is_parent} = $type eq 'parent';
  return $data;
}

sub encode_model_event ($self, $event) {
  return {
    id      => $event->id,
    name    => $event->name,
    year    => $event->year,
    address => $self->encode_model($event->address),
  };
}

sub encode_model_eventgroup ($self, $entity) {
  my $r = {
    id       => $entity->id,
    name     => $entity->name,
    isParent => $entity->is_parent,
    url      => $entity->url,
  };

  if (ref($self->resultset) =~ /UserEventActivity/) {
    my $user = $self->current_user;
    if (my $username = $self->validation->param('username')) {
      $user = $self->model('User')->find({username => $username});
    }
    $r->{events} = $self->encode_model([$entity->user_event_activities->for_user($user)->visible_to($self->current_user)->all]);
  }

  return $r;
}

sub resultset ($self, @args) {
  my $rs = $self->SUPER::resultset(@args);

  if (my $name = $self->validation->param('name')) {
    $rs = $rs->filter_name($name);
  }
  if (my $type = $self->validation->param('type')) {
    $rs = $rs->type_series if ($type eq 'series');
    $rs = $rs->type_parent if ($type eq 'parent');
  }

  return $rs;
}

1;

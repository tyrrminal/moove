package Moove::Controller::Workout;
use v5.36;

use Mojo::Base 'DCS::Base::API::Model::Controller';

use Role::Tiny::With;
with 'DCS::Base::Role::Rest::Collection', 'DCS::Base::Role::Rest::Entity';
with 'Moove::Controller::Role::ModelEncoding::Workout';

use DCS::Base::Exception::Authorization;
use DCS::Util::NameConversion qw(convert_hash_keys camel_to_snake);

use List::Util qw(sum min max);

sub decode_model ($self, $data) {
  my $d = {convert_hash_keys($data->%*, \&camel_to_snake)};
  return $d;
}

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

sub insert_record ($self, $data) {
  $data->{user_id} = $self->current_user->id;
  $self->SUPER::insert_record($data);
}

sub update_record ($self, $entity, $data) {
  DCS::Base::Exception::Authorization->raise() unless ($entity->user->id == $self->current_user->id);
  my $adjust = delete($data->{adjust_activity_dates});
  my $r      = $self->SUPER::update_record($entity, $data);
  if ($adjust) {
    $entity->discard_changes;
    foreach my $result ($entity->activities->completed->related_resultset('activity_result')->all) {
      if (my $st = $result->start_time) {
        $st->set(year => $entity->date->year, month => $entity->date->month, day => $entity->date->day);
        $result->update({start_time => $st});
      }
    }
  }
  return $r;
}

sub delete_record ($self, $entity) {
  DCS::Base::Exception::Authorization->raise() unless ($entity->user->id == $self->current_user->id);
  $self->SUPER::delete_record($entity);
}

1;

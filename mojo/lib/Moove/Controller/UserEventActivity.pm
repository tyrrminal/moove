package Moove::Controller::UserEventActivity;
use Mojo::Base 'DCS::Base::API::Model::Controller';

use Role::Tiny::With;
with 'DCS::Base::Role::Rest::Collection', 'DCS::Base::Role::Rest::Entity';
with 'Moove::Controller::Role::ModelEncoding::UserEventActivity',
  'Moove::Controller::Role::ModelEncoding::Activity',
  'Moove::Controller::Role::ModelEncoding::ActivityType',
  'Moove::Controller::Role::ModelEncoding::EventPlacement',
  'Moove::Controller::Role::ModelEncoding::EventType',
  'Moove::Controller::Role::ModelEncoding::Registration::Event',
  'Moove::Controller::Role::ModelEncoding::Registration::EventActivity';

use experimental qw(signatures postderef switch);

sub decode_model ($self, $data) {
  return $data;
}

sub resultset ($self) {
  my $rs = $self->unfiltered_resultset()->search(
    undef, {
      join => {event_registration => 'event_activity'}
    }
  );

  if (my $start = $self->validation->param('start')) {
    $rs = $rs->on_or_after($self->parse_api_date($start));
  }
  if (my $end = $self->validation->param('end')) {
    $rs = $rs->on_or_before($self->parse_api_date($end));
  }
  if (my $group_id = $self->validation->param('eventGroupID')) {
    $rs = $rs->in_group($group_id);
  }

  return $rs;
}

sub custom_sort_for_column ($self, $col) {
  given ($col) {
    when ('scheduledStart') {return 'event_activity.scheduled_start'}
    default                 {return undef}
  }
}

sub unfiltered_resultset ($self) {
  my $rs = $self->SUPER::unfiltered_resultset()->visible_to($self->current_user);

  my $user = $self->current_user;
  if (my $username = $self->validation->param('username')) {
    $user = $self->model('User')->find({username => $username});
  }
  return $rs->for_user($user);
}

1;

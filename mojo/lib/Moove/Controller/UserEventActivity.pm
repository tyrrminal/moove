package Moove::Controller::UserEventActivity;
use v5.36;

use Mojo::Base 'DCS::Base::API::Model::Controller';

use Role::Tiny::With;
with 'DCS::Base::Role::Rest::Collection', 'DCS::Base::Role::Rest::Entity';
with 'Moove::Controller::Role::ModelEncoding::UserEventActivity',
  'Moove::Controller::Role::ModelEncoding::UserEventActivity::Activity',
  'Moove::Controller::Role::ModelEncoding::ActivityType',
  'Moove::Controller::Role::ModelEncoding::EventPlacement',
  'Moove::Controller::Role::ModelEncoding::EventType',
  'Moove::Controller::Role::ModelEncoding::Registration::Event',
  'Moove::Controller::Role::ModelEncoding::Registration::EventActivity';

use DCS::Util::NameConversion qw(camel_to_snake convert_hash_keys);

sub decode_model ($self, $data) {
  $data = {convert_hash_keys($data->%*, \&camel_to_snake)};
  if (exists($data->{fundraising})) {
    $data->{fundraising_requirement} = $data->{fundraising}->{minimum};
    delete($data->{fundraising});
  }
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
  if (defined($self->validation->param('activityTypeID'))) {
    my $activity_type_ids = $self->validation->every_param('activityTypeID');
    foreach my $activity_type_id ($activity_type_ids->@*) {
      $self->model_find(ActivityType => $activity_type_id) or return $self->render_not_found('ActivityType');
    }
    $rs = $rs->search({'event_type.activity_type_id' => {-in => $activity_type_ids}},{join => {event_registration => {event_activity => 'event_type'}}});
  }
  if (my $event_activity_id = $self->validation->param('eventActivityID')) {
    $rs = $rs->search(
      {
        event_activity_id => $event_activity_id
      }
    );
  }

  return $rs;
}

sub custom_sort_for_column ($self, $col) {
  return 'event_activity.scheduled_start' if ($col eq 'scheduledStart');
  return undef;
}

sub unfiltered_resultset ($self) {
  my $rs = $self->SUPER::unfiltered_resultset()->visible_to($self->current_user);

  my $user = $self->current_user;
  if (my $username = $self->validation->param('username')) {
    $user = $self->model('User')->find({username => $username});
  }
  return $rs->for_user($user);
}

sub insert_record ($self, $data) {
  my $registration = {
    event_activity_id   => delete($data->{event_activity_id}),
    registration_number => delete($data->{registration_number}),
  };
  my $er = $self->model('EventRegistration')->create($registration);
  $data->{event_registration_id} = $er->id;
  $data->{user_id}               = $self->current_user->id;
  $self->SUPER::insert_record($data);
}

sub update_record ($self, $entity, $data) {
  delete($data->{event_activity_id});
  my $registration = {registration_number => delete($data->{registration_number}),};
  $entity->event_registration->update($registration);
  $self->SUPER::update_record($entity, $data);
}

sub delete_record ($self, $entity) {
  my $er = $entity->event_registration;
  $self->SUPER::delete_record($entity);
  $er->delete();
}

1;

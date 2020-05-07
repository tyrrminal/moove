package Moove::Controller::User;
use Mojo::Base 'DCS::API::Base::ModelController';
use Role::Tiny::With;

with 'DCS::API::Role::Rest::Create',
  'DCS::API::Role::Rest::Delete',
  'DCS::API::Role::Rest::Get',
  'DCS::API::Role::Rest::List',
  'DCS::API::Role::Rest::Update';
with 'Moove::Controller::Role::ModelEncoding::EventRegistration', 'Moove::Controller::Role::ModelEncoding::Default';
with 'Moove::Controller::Role::ModelDecoding::User';

use DCS::Constants qw(:boolean);

use experimental qw(signatures);

sub resultset($self) {
  my $rs = $self->SUPER::resultset();
  if (my $username = $self->validation->param('username')) {
    $rs = $rs->search({username => {-like => "%$username%"}});
  }
  return $rs;
}

sub update_authorized ($self, $user) {
  return $user->id == $self->current_user->id;
}

sub perform_update ($self, $user, $data) {
  $user->person->update(delete($data->{person})) if (exists($data->{person}));
  $user->update($data);
}

sub delete_authorized ($self, $user) {
  return $user->id == $self->current_user->id;
}

sub perform_delete ($self, $user) {
  my $person = $user->person;
  $user->delete;
  $person->delete unless ($person->donations->count || $person->participants->count);
}

sub get_summary($self) {
  return unless ($self->openapi->valid_input);

  my $user_id = $self->validation->param('user');

  my $user = $self->model_find(User => $user_id)
    or return $self->render_not_found("User '$user_id' unknown");
  my $reg = $user->event_registrations;

  return $self->render(
    openapi => $self->render_model(
      {
        user              => $user,
        recent_activities => [$user->activities->whole->ordered('-desc')->slice(0, 4)],
        events            => {
          previous => $reg->past->ordered('-desc')->first,
          next     => $reg->future->ordered('-asc')->first
        },
        goals  => [$user->user_goals->fulfilled('-desc')->slice(0, 4)],
        totals => [$user->cumulative_totals],
      }
    )
  );
}

1;

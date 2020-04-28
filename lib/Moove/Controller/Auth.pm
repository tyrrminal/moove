package Moove::Controller::Auth;
use Mojo::Base 'DCS::API::Base::Controller';
use Role::Tiny::With;

with 'Moove::Controller::Role::ModelEncoding::AuthUser';
with 'Moove::Controller::Role::ModelEncoding::Default';

use DateTime;

use experimental qw(signatures);

sub db_to_api($self) {
  my $u = $self->current_user;
  return {
    user       => $self->render_model($self->current_user),
    expiration => $self->session_expiration
  };
}

sub login($self) {
  my $c = $self->openapi->valid_input or return;

  my $username = delete($c->session->{auth_username});
  if (my $u = $c->model('User')->find({username => $username})) {
    $c->session(uid => $u->id);
    $self->db->stash->{uid} = $u->id;
    return $c->render(openapi => $self->db_to_api);
  }

  return $c->render(
    status  => 404,
    openapi => {message => "User '$username' unknown"}
  );
}

sub status($self) {
  my $c = $self->openapi->valid_input or return;

  return $c->render(openapi => $self->db_to_api);
}

sub logout($self) {
  my $c = $self->openapi->valid_input or return;

  $c->session({uid => undef, expires => 1});

  return $c->render(status => 204, openapi => q{});
}

sub session_expiration($self) {
  my $c = $self->openapi->valid_input or return;

  my $d;
  if ($d = $c->session('expiration')) {
    $d += time;
  } elsif ($d = $c->session('expires')) {

  } else {
    $d = time + $c->app->sessions->default_expiration * 24 * 30;
  }

  return DateTime->from_epoch(epoch => $d, time_zone => 'local')->iso8601;
}

1;

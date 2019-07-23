package CardioTracker::Controller::API::V1::Auth;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use DateTime;

sub login($self) {
  my $c = $self->openapi->valid_input or return;

  my $username = $c->param('username');

  if (my $u = $c->model('User')->search({username => $username})->first) {
    $c->session(uid => $u->id);
    return $c->render(
      status  => 200,
      openapi => { user => $u->to_hash, expiration => $c->session_expiration }
    );
  }

  return $c->render(
    status  => 404,
    openapi => {message => "User '$username' unknown"}
  );
}

sub status($self) {
  my $c = $self->openapi->valid_input or return;
  
  return $c->render(
    status  => 200,
    openapi => { user => $self->current_user->to_hash, expiration => $c->session_expiration }
  );
}

sub logout($self) {
  my $c = $self->openapi->valid_input or return;

  $c->session({uid => undef, expires => 1});

  return $c->render(status => 204, openapi => '');
}

sub session_expiration($self) {
  my $c = $self->openapi->valid_input or return;

  my $d;
  if($d = $c->session('expiration')) {
    $d += time;
  } elsif($d = $c->session('expires')) {
    
  } else {
    $d = time + $c->app->sessions->default_expiration;
  }

  return DateTime->from_epoch(epoch => $d, time_zone => 'local')->iso8601;
}

1;

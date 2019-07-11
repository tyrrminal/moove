package CardioTracker::Controller::API::V1::Auth;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub login($self) {
  my $c = $self->openapi->valid_input or return;

  my $username = $c->param('username');

  if (my $u = $c->model('User')->search({username => $username})->first) {
    $c->session(uid => $u->id);
    return $c->render(
      status  => 200,
      openapi => $u->to_hash
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
    openapi => $self->current_user->to_hash
  );
}


sub logout($self) {
  my $c = $self->openapi->valid_input or return;

  $c->session({uid => undef, expires => 1});

  return $c->render(status => 204, openapi => '');
}

1;

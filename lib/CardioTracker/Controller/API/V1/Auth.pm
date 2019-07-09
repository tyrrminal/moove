package CardioTracker::Controller::API::V1::Auth;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use Mojo::JSON qw(encode_json);
use Mojo::Util qw(b64_encode);

sub login($self) {
  my $c = $self->openapi->valid_input or return;
  
  my $username = $c->param('username');

  if(my $u = $c->model('User')->search({ username => $username })->first) {
    $c->session(uid => $u->id);
    my $user_cookie = b64_encode(encode_json({ id => $u->id, username => $u->username}),"");
    $c->cookie(cardiotracker => $user_cookie, { path => '/', expires => time + 60*60});
    return $c->render(status => 200, openapi => 'success');
  }

  return $c->render(status => 404, openapi => "User '$username' unknown");
}

sub logout($self) {
  my $c = $self->openapi->valid_input or return;

  $c->session(
    {
      uid => undef,
      expires => 1
    }
  );
  $c->cookie(cardiotracker => '', { path => '/', expires => 1 });

  return $c->render(status => 200, openapi => 'success');
}

1;

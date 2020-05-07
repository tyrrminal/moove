package Mojolicious::Plugin::DCS::Authorization;


use Mojo::Base 'Mojolicious::Plugin';

use Memoize;
use Memoize::Expire;
use Time::Seconds;
use syntax 'junction';

use experimental qw(signatures);

sub register ($self, $app, $args) {

  my $get_roles_for_username = sub($username) {
    return ['admin'] if ($username eq 'digicow');
    return [];
  };

  $app->helper(
    roles_for_user => sub ($self, $user) {
      return $get_roles_for_username->($user->username);
    }
  );
}

# OpenAPI Security Callback
sub api_session ($c, $definition, $scopes, $cb) {
  my $u = $c->current_user;
  return $c->$cb('User not authenticated') if ($u->is_guest);
  return $c->$cb() unless (@{$scopes});    # no role requirement
  return $c->$cb() if (any(@{$c->current_user_roles}) eq any(@{$scopes}));    # met role requirement
  return $c->$cb('User not authorized');
}

1;

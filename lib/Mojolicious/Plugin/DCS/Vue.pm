package Mojolicious::Plugin::DCS::Vue;
use Mojo::Base 'Mojolicious::Plugin';

use experimental qw(signatures);

sub register ($self, $app, $args) {
  # Route everything that other routes haven't picked up to Vue
  $app->routes->any(
    '/*catchall' => {catchall => ''} => sub($c) {
      $c->reply->static('index.html');
    }
  );
}

1;

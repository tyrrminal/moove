package CardioTracker::Helper::Vue;
use Mojo::Base 'Mojolicious::Plugin', -signatures;

sub register($self, $app, $args) {
  # Route everything that other routes haven't picked up to Vue
  $app->routes->any('/*catchall' => {catchall => ''} => sub($c) {
    $c->reply->static('index.html');
  })
}

1;
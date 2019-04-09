package CardioTracker::Helper::Vue;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($self, $app) = @_;

  # Route everything that other routes haven't picked up to Vue
  $app->routes->any('/*catchall' => {catchall => ''} => sub {
    my $c = shift;
    $c->reply->static('index.html');
  })
}

1;
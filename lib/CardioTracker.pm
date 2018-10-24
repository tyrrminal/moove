package CardioTracker;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Load configuration from hash returned by "my_app.conf"
  #my $config = $self->plugin('Config');

  push @{ $self->commands->namespaces }, 'CardioTracker::Command';

  $self->plugin('DCS::Plugin::Config');
  $self->plugin('CardioTracker::Helper::DB');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
}

1;

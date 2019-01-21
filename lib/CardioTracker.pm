package CardioTracker;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  push @{ $self->commands->namespaces }, 'CardioTracker::Command';

  $self->plugin('DCS::Plugin::Config');
  $self->plugin('CardioTracker::Helper::DB');
  $self->plugin('CardioTracker::Helper::Session');
  $self->plugin('CardioTracker::Helper::String_Formatting');
  $self->plugin('CardioTracker::Helper::API');

  push @{$self->static->paths}, $self->conf->static_assets->path;

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');

  my $legacy = $r->any('/legacy')->to(controller => 'legacy');
    $legacy->get('/summary/:username')->to(action => 'summary', username => $self->current_user->username);
    $legacy->get( '/events/:username')->to(action => 'events', username => $self->current_user->username);
    $legacy->get( '/cardio/:username')->to(action => 'cardio', username => $self->current_user->username);
}

1;

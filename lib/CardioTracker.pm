package CardioTracker;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  push @{ $self->commands->namespaces }, 'CardioTracker::Command';

  $self->plugin('DCS::Plugin::Config');
  $self->secrets($self->conf->secrets);

  $self->plugin('CardioTracker::Helper::DB');
  $self->plugin('CardioTracker::Helper::Session');
  $self->plugin('CardioTracker::Helper::String_Formatting');
  $self->plugin('CardioTracker::Helper::API');
  $self->plugin('CardioTracker::Helper::Vue');

  # Router
  # my $r = $self->routes;

  # my $legacy = $r->get('/legacy')->to(controller => 'legacy', username => $self->current_user->username);
  #   $legacy->get('/summary/:username')->to(action => 'summary');
  #   $legacy->get('/events/:username')->to(action => 'events');
  #   $legacy->get('/activities/:username')->to(action => 'cardio');
}

1;

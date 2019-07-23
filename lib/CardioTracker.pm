package CardioTracker v0.3.0;
use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup($self) {
  push @{$self->commands->namespaces}, 'CardioTracker::Command';

  $self->plugin('Mojolicious::Plugin::DCS::Config');
  $self->secrets($self->conf->secrets);

  $self->plugin('CardioTracker::Helper::DB');
  $self->plugin('CardioTracker::Helper::Session');
  $self->plugin('CardioTracker::Helper::String_Formatting');
  $self->plugin('CardioTracker::Helper::API');
  $self->plugin('CardioTracker::Helper::Vue');
}

1;

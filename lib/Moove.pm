package Moove v0.2.0;
use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup($self) {
  push @{$self->commands->namespaces}, 'Moove::Command';

  $self->plugin('Mojolicious::Plugin::Config::Structured' => {config_file => $ENV{MOOVE_CONFIG}});
  $self->secrets($self->conf->secrets);

  $self->plugin('Moove::Helper::DB');
  $self->plugin('Moove::Helper::Session');
  $self->plugin('Moove::Helper::String_Formatting');
  $self->plugin('Moove::Helper::API');
  $self->plugin('Moove::Helper::Vue');
}

1;

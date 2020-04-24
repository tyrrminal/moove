package Moove v0.2.0;
use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup($self) {
  push @{$self->commands->namespaces}, 'Moove::Command';

  $self->plugin(
    'Config::Structured' => {
      structure_file => $self->app->home->child('cfg')->child('structure.yml')->to_string,
      config_file    => $ENV{MOOVE_CONFIG}
    }
  );
  $self->secrets($self->conf->secrets);

  $self->conf->_add_helper(
    db_params => sub {
      my $db = shift->db;
      return (sprintf('dbi:mysql:database=%s;host=%s;port=%d', $db->name, $db->host, $db->port), $db->user, $db->pass);
    }
  );

  $self->plugin('Moove::Helper::DB');
  $self->plugin('Moove::Helper::Session');
  $self->plugin('Moove::Helper::API');
  $self->plugin('Moove::Helper::Vue');
}

1;

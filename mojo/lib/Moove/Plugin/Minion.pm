package Moove::Plugin::Minion;
use v5.36;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::File;

sub register ($self, $app, $args) {
  my $conf = $app->conf->db;
  $app->plugin(
    Minion => {
      SQLite => File::Spec->catfile($app->conf->paths->var, 'Minion.db')
    }
  );

  $app->plugin('Moove::Task::ActivityPoint');
  $app->plugin('Moove::Task::EventResult');
}

1;

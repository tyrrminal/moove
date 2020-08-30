package Moove::Command::qtest;
use Mojo::Base 'Mojolicious::Command', -signatures;

use Data::Dumper;

has 'description' => 'Quick test functionality';
has 'usage'       => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run ($self, @args) {
  say $self->app->conf->db->pass;
}

1;

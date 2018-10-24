package CardioTracker::Command::qtest;
use Mojo::Base 'Mojolicious::Command';

use Modern::Perl;

use DCS::Constants;
use Data::Dumper;

has 'description' => 'Quick test functionality';
has 'usage' => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run {
  my ($self, @args) = @_;

  say $self->app->conf->db->pass;
}

1;

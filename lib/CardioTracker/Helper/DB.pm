package CardioTracker::Helper::DB;
use Mojo::Base 'Mojolicious::Plugin', -signatures;

use CardioTracker::Model;

use Data::Dumper;

sub register($self, $app, $args) {

  $app->helper(
    db => sub($c) {
      my $cfg = $app->conf->db;
      state $db = CardioTracker::Model->new($cfg->dsn,$cfg->user,$cfg->pass);
    }
  );

  $app->helper(
    model => sub($self, $model) {
      return $self->db->resultset($model);
    }
  );
}

1;

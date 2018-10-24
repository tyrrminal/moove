package CardioTracker::Helper::DB;

use Mojo::Base 'Mojolicious::Plugin';

use CardioTracker::Model;

use Data::Dumper;

sub register {
  my ($self, $app) = @_;

  $app->helper(
    db => sub {
      my $c = $app->conf->db;
      state $db = CardioTracker::Model->new($c->dsn,$c->user,$c->pass);
    }
  );

  $app->helper(
    model => sub {
      my ($self, $model) = @_;
      return $self->db->resultset($model);
    }
  );
}

1;

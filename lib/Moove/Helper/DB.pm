package Moove::Helper::DB;
use Mojo::Base 'Mojolicious::Plugin', -signatures;

use Moove::Model;

use Data::Dumper;

sub register ($self, $app, $args) {

  $app->helper(
    db => sub($c) {
      state $db = Moove::Model->new($app->conf->db_params);
    }
  );

  $app->helper(
    model => sub ($self, $model) {
      return $self->db->resultset($model);
    }
  );

  $app->helper(
    retrieve => sub ($self, $model, $id) {
      if ($id and my $m = $self->model($model)) {
        return $m->find($id);
      }
      return undef;
    }
  );
}

1;

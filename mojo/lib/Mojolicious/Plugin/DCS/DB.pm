package Mojolicious::Plugin::DCS::DB;



use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Util qw(class_to_path);

use experimental qw(signatures);

sub register ($self, $app, $args) {

  $app->helper(
    model_class => sub($self) {
      return $args->{model_class};
    }
  );
  require(class_to_path($app->model_class));

  $app->conf->_add_helper(
    db_params => sub {
      my $db = shift->db;
      return (sprintf('dbi:mysql:database=%s;host=%s;port=%d', $db->name, $db->host, $db->port), $db->user, $db->pass);
    }
  );

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
}

1;

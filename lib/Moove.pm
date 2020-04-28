package Moove v1.0.0;
use Mojo::Base 'Mojolicious';

use experimental qw(signatures);

# This method will run once at server start
sub startup($self) {
  $self->plugin(
    'DCS::Base',
    dbix_components => [qw(InflateColumn::Time)],
    api_definition  => $self->app->home->child('api')->child('moove-api-v1.yaml')->to_string,
    conf_structure  => $self->app->home->child('cfg')->child('structure.yml')->to_string
  );
}

1;

package Moove v2.0.0;
use v5.36;

use Mojo::Base 'Mojolicious';

use Mojolicious::Plugin::DCS::Base::Constants qw(:dbix);

# This method will run once at server start
sub startup ($self) {
  $self->plugin(
    'DCS::Base',
    cron          => undef,
    persistentlog => undef,
    datastore     => {load_schema_options => {components => [@DEFAULT_DBIX_COMPONENTS, qw(InflateColumn::Time)]}},
  );
}

1;
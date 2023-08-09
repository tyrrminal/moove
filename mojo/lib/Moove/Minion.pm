package Moove::Minion;
use v5.38;

use Mojo::Base 'Mojolicious';

use Mojolicious::Plugin::DCS::Base::Constants qw(:dbix);

sub startup ($self) {
  $self->moniker('Moove');
  $self->plugin(
    'DCS::Base',
    cron          => undef,
    persistentlog => undef,
    datastore     => {load_schema_options => {components => [@DEFAULT_DBIX_COMPONENTS, qw(InflateColumn::Time)]}},
  );
  $self->plugin('Moove::Plugin::Minion');
}

1;

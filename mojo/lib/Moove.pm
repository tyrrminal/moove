package Moove v2.2.12;
use v5.38;

use Mojo::Base 'Mojolicious';

use Mojolicious::Plugin::DCS::Base::Constants qw(:dbix);

use DCS::Constants qw(:symbols);

# This method will run once at server start
sub startup ($self) {
  $self->plugin(
    'DCS::Base',
    cron          => undef,
    persistentlog => undef,
    datastore     => {
      load_schema_options => {
        components            => [@DEFAULT_DBIX_COMPONENTS, qw(InflateColumn::Time)],
        filter_generated_code => sub ($type, $class, $text) {
          return join($NEWLINE, '#<<<', $text . '#>>>', 'use v5.38;');
        }
      }
    },
  );
  $self->plugin('Moove::Plugin::Minion');
  $self->plugin('Minion::Admin');
}

1;

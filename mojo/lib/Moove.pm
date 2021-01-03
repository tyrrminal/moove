package Moove v2.0.0;
use Mojo::Base 'Mojolicious';

use experimental qw(signatures);

# This method will run once at server start
sub startup($self) {
  $self->plugin(
    'DCS::Base',
    cron          => undef,
    persistentlog => undef,
    dbix          => {components => [qw(InflateColumn::Time)]},
  );
}

1;

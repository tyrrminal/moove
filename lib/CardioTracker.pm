package CardioTracker;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  push @{ $self->commands->namespaces }, 'CardioTracker::Command';

  $self->plugin('DCS::Plugin::Config');
  $self->plugin('CardioTracker::Helper::DB');
  $self->plugin('CardioTracker::Helper::Session');
  $self->plugin('CardioTracker::Helper::String_Formatting');
  $self->plugin('CardioTracker::Helper::API');

  push @{$self->static->paths}, $self->conf->static_assets->path;

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');

  $r->get('/legacy/cardio')->to('legacy#cardio')->name('excel_cardio');
  $r->get('/legacy/summary')->to('legacy#summary')->name('excel_summary');
  $r->get('/legacy/events')->to('legacy#events')->name('excel_events');
}

1;

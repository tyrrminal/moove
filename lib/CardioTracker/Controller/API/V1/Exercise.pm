package CardioTracker::Controller::API::V1::Exercise;
use Mojo::Base 'Mojolicious::Controller';

sub get {
  my $self=shift;
  $self->app->log->info('Invoked');

  my $c = $self->openapi->valid_input or return;

  return $c->render(openapi => {});
}


1;

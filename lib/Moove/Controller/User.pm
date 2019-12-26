package Moove::Controller::User;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use DCS::Constants qw(:boolean);

sub get_summary($self) {
  my $c = $self->openapi->valid_input or return;
  my $user_id = $c->validation->param('user');

  my $u = $c->retrieve('User', $user_id) or return $self->render_not_found("User '$user_id' unknown");

  my @recent = $u->activities->whole->ordered('-desc')->slice(0, 4);

  my @results = $c->model('CumulativeTotal')->overall_results;

  my $reg = $u->event_registrations;
  my %e   = (
    previous => $reg->past->visible_to($c->current_user)->ordered('-desc')->first,
    next     => $reg->future->visible_to($c->current_user)->ordered('-asc')->first
  );
  foreach (keys(%e)) {
    if (defined($e{$_})) {$e{$_} = $e{$_}->to_hash_complete;}
    else                 {delete($e{$_});}
  }
  return $c->render(
    status  => 200,
    openapi => {
      user              => $u->to_hash,
      recent_activities => [map {$_->to_hash} @recent],
      events            => {%e},
      goals             => [map {$_->to_hash(fulfillments => $TRUE)} $u->user_goals->fulfilled('-desc')->slice(0, 4)],
      totals => [map {$_->to_hash} @results]
    }
  );
}

1;

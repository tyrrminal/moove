package CardioTracker::Controller::API::V1::User;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use DCS::Constants qw(:boolean);

sub get_summary($self) {
  my $c = $self->openapi->valid_input or return;
  my $user_id = $c->validation->param('user');

  if (my $u = $c->model('User')->find_user($user_id)) {
    my @recent = $u->activities->whole->ordered('-desc')->slice(0, 4);

    return $c->render(
      status  => 200,
      openapi => {
        user              => $u->to_hash,
        recent_activities => [map {$_->to_hash} @recent],
        events            => {
          previous => $u->event_registrations->past->ordered('-desc')->first->to_hash(complete  => $TRUE),
          next     => $u->event_registrations->future->ordered('-asc')->first->to_hash(complete => $TRUE)
        }
      }
    );
  }

  return $c->render(
    status  => 404,
    openapi => {message => "User '$user_id' unknown"}
  );
}

1;

package CardioTracker::Helper::Session;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($self, $app) = @_;

  $app->helper(current_user => sub {
    my $u = shift->model('User');
    if(my $user = $u->find(1)) {
      return $user;
    }
    return $u->anonymous;
  });
}

1;

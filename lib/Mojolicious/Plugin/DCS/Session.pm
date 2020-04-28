package Mojolicious::Plugin::DCS::Session;
use Mojo::Base 'Mojolicious::Plugin';

use Time::Seconds;

use experimental qw(signatures);

sub register ($self, $app, $args) {
  $app->sessions->default_expiration(ONE_WEEK);

  $app->helper(
    current_user => sub($c) {
      my $model = $c->model('User');
      if (my $uid = $c->session('uid')) {
        if (my $user = $model->find($uid)) {
          return $user;
        }
      }
      return $model->guest;
    }
  );

  $app->helper(
    current_user_roles => sub($c) {
      $c->roles_for_user($c->current_user);
    }
  );

  $app->helper(
    is_admin => sub($c) {
      return any($c->current_user_roles) eq any(qw(admin));
    }
  );

}

1;

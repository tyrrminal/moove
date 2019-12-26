package Moove::Helper::Session;

use Mojo::Base 'Mojolicious::Plugin', -signatures;

sub register ($self, $app, $args) {

  $app->helper(
    current_user => sub($c) {
      my $model = $c->model('User');
      if (my $uid = $c->session('uid')) {
        if (my $user = $model->find($uid)) {
          return $user;
        }
      }
      return $model->anonymous;
    }
  );

}

1;

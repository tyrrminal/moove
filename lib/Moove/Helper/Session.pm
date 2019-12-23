package Moove::Helper::Session;

use Mojo::Base 'Mojolicious::Plugin', -signatures;

sub register($self, $app, $args) {

  $app->helper(current_user => sub($c) {
    my $u = $c->model('User');
    if(my $uid = $c->session('uid')) {
      if(my $user = $u->find($uid)) {
        return $user;
      }
    }
    return $u->anonymous;
  });
  
}

1;

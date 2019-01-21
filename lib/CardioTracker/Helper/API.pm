package CardioTracker::Helper::API;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($self, $app) = @_;
  
  $app->plugin("OpenAPI" => {
    url => $app->home->rel_file("cardiotracker-api.json"),
    security => {
      user => sub {
        my ($c, $definition, $scopes, $cb) = @_;
        my $u = $c->current_user;
        return $c->$cb("User not authenticated") unless($u->id);
        return $c->$cb();
      },
      admin => sub {
        my ($c, $definition, $scopes, $cb) = @_;
        my $u = $c->current_user;
        return $c->$cb("User not authenticated") unless($u->id);
        return $c->$cb("User not privileged") unless($u->is_admin);
        return $c->$cb();
      }
    }
  });
}

1;

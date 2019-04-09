package CardioTracker::Helper::API;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($self, $app) = @_;

    # CORS (needed for dev, at least)
  $app->hook(
    before_dispatch => sub {
      my $c = shift;
      my $origin = $c->req->headers->header('Origin');
      if(defined($origin) && $origin =~ /digicow.net/) {
        $c->res->headers->header('Access-Control-Allow-Origin' => $origin);
      }
    }
  );
  
  $app->helper(render_error => sub {
    my $c = shift;
    my ($code,$message,$suffix) = @_;
    my $path = $c->req->url->to_abs->path;
    if(defined($suffix)) {
      if($suffix =~ m|^/|) {
        $path = $suffix;
      } else {
        $path .= "/$suffix";
      }
    }

    return $c->render(status => $code, json => { errors => [ {
			message => $message,
		 	   path => $path
		} ] } );
  });

  $app->plugin("OpenAPI" => {
    url => $app->home->rel_file("api/cardiotracker-api-oapiv3.yaml"),
    schema => 'v3',
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
  $app->routes->any('/api/*catchall' => {catchall => ''} => sub {
    my $c        = shift;
    my $catchall = $c->param('catchall');
    $c->reply->not_found
  });
}

1;

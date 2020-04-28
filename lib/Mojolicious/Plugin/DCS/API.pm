package Mojolicious::Plugin::DCS::API;
use Mojo::Base 'Mojolicious::Plugin';

use HTTP::Status qw(:constants);

use Mojolicious::Plugin::DCS::Authentication;
use Mojolicious::Plugin::DCS::Authorization;

use experimental qw(signatures);

sub register ($self, $app, $args) {
  $app->plugin(
    "OpenAPI" => {
      url    => $args->{api_definition},
      schema => 'v3',
      default_response_codes =>
        [HTTP_BAD_REQUEST, HTTP_UNAUTHORIZED, HTTP_FORBIDDEN, HTTP_NOT_FOUND, HTTP_INTERNAL_SERVER_ERROR, HTTP_NOT_IMPLEMENTED],
      security => $args->{security}
    }
  );
  $app->routes->any(
    '/api/*catchall' => {catchall => ''} => sub($c) {
      my $catchall = $c->param('catchall');
      $c->reply->not_found;
    }
  );
}

1;

package Moove::Helper::API;
use Mojo::Base 'Mojolicious::Plugin', -signatures;

use Syntax::Keyword::Try;
use Mojo::Util qw(b64_decode);

use Net::LDAP;

use DCS::Constants qw(:symbols);

sub register ($self, $app, $args) {
  $app->sessions->default_expiration(24 * 60 * 60);

  $app->helper(
    'check_credentials' => sub ($self, $username, $password) {
      if ($username =~ /@/) {
        # Internet identify provider
      } else {
        # LDAP identity provider
        my $dn = sprintf($self->conf->ldap->user_basedn, $username);
        my $conn = Net::LDAP->new($self->conf->ldap->host) or die "$@";
        my $msg = $conn->bind($dn, password => $password);
        return 1 unless ($msg->is_error());
      }

      return 0;
    }
  );

  $app->plugin(
    "OpenAPI" => {
      url      => $app->home->rel_file("api/moove-api-v1.yaml"),
      schema   => 'v3',
      security => {
        auth => sub ($c, $definition, $scopes, $cb) {
          return $c->$cb('Invalid Authentication scheme') unless (($c->req->headers->authorization // $EMPTY) =~ /Basic (.*)/);
          my ($un, $pw) = split(q{:}, b64_decode($1));
          return $c->$cb('Invalid Credentials') unless ($app->check_credentials($un, $pw));    # TODO: implement credential checking
          $c->session(auth_username => $un);    #temporary session var to be consumed exclusively by Auth#login
          return $c->$cb();
        },
        user => sub ($c, $definition, $scopes, $cb) {
          my $u = $c->current_user;
          return $c->$cb("User not authenticated") unless ($u->id);
          return $c->$cb();
        },
        admin => sub ($c, $definition, $scopes, $cb) {
          my $u = $c->current_user;
          return $c->$cb("User not authenticated") unless ($u->id);
          return $c->$cb("User not privileged")    unless ($u->is_admin);
          return $c->$cb();
        }
      }
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

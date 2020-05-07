package Mojolicious::Plugin::DCS::Authentication;


use Mojo::Base 'Mojolicious::Plugin';

use Net::LDAP;
use Mojo::Util qw(b64_decode);

use DCS::Constants qw(:boolean :symbols);

use experimental qw(signatures);

sub register ($self, $app, $args) {

}

sub check_credentials ($self, %params) {
  my ($username, $password) = @params{qw(user pass)};
  if ($username =~ /@/) {
    # Internet identify provider
  } else {
    # LDAP identity provider
    my $dn = sprintf($self->conf->ldap->user_basedn, $username);
    my $conn = Net::LDAP->new($self->conf->ldap->host) or die "$@";
    my $msg = $conn->bind($dn, password => $password);
    return $TRUE unless ($msg->is_error());
  }

  return $FALSE;
}

sub api_password ($c, $definition, $scopes, $cb) {
  return $c->$cb('Invalid Authentication scheme') unless ($c->req->headers->authorization =~ /Basic (.*)/);
  my ($un, $pw) = split($COLON, b64_decode($1));
  return $c->$cb('Invalid Credentials') unless (check_credentials($c, user => $un, pass => $pw));
  $c->session(auth_username => $un);    #temporary session var to be consumed exclusively by Concert::API::Base::Auth#login
  return $c->$cb();
}

1;

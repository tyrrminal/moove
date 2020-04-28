package Mojolicious::Plugin::DCS::Base;

# ABSTRACT: Provides mojo base functionality for DCS Vue apps

use Mojo::Base 'Mojolicious::Plugin';

use Exporter;

use Readonly;
use List::MoreUtils qw(first_index);
use DCS::Constants qw(:symbols :boolean);

use experimental qw(signatures);

Readonly::Scalar my $DOUBLE_COLON => $COLON x 2;

# Feature load order
my @features = (
  {textbalancedfix => \&_load_base_textbalancedfix},
  {commands        => \&_load_base_commands},
  {config          => \&_load_base_config},
  {authentication  => \&_load_base_authentication},
  {authorization   => \&_load_base_authorization},
  {datastore       => \&_load_base_datastore},
  {session         => \&_load_base_session},
  {openapi         => \&_load_base_openapi},
  {vue             => \&_load_base_vue},
  {schemaload      => \&_configure_load_schema},
);
my @loaded = ();
sub _is_module_loaded($module) {
  return (first_index {$_ eq 'authentication'} @loaded) >= 0;
}

sub import ($class, @args) {
  foreach (@args) {
    if (/^no-(.*)/) {
      if (my $idx = first_index {exists($_->{$1})} @features) {
        splice(@features, $idx, 1);
      } else {
        warn("Unknown DCS::Base feature '$1'\n");
      }
    }
  }
}

sub _load_base_textbalancedfix ($app, $args) {
# DBIx::Class::_Util::is_exception(): External exception class Text::Balanced::ErrorMsg implements partial (broken) overloading preventing its instances from being used in simple ($x eq $y) comparisons.
# Given Perl's "globally cooperative" exception handling this type of brokenness is extremely dangerous on exception objects, as it may (and often does) result in silent "exception substitution".
# DBIx::Class tries to work around this as much as possible, but other parts of your software stack may not be even aware of this. Please submit a bugreport against the distribution containing Text::Balanced::ErrorMsg
# and in the meantime apply a fix similar to the one shown at http://v.gd/DBIC_overload_tempfix/, in order to ensure your exception handling is saner application-wide.

  # hacky workaround for desperate folk
  # intended to be copypasted into your app
  {
    require Text::Balanced;
    require overload;

    local $@;

    # this is what poisons $@
    Text::Balanced::extract_bracketed('(foo', '()');

    if ($@ and overload::Overloaded($@) and !overload::Method($@, 'fallback')) {
      my $class = ref $@;
      eval "package $class; overload->import(fallback => 1);";
    }
  }
  # end of hacky workaround

  return $TRUE;
}

sub _configure_load_schema ($app, $args) {
  $app->helper(
    dbix_components => sub {
      return $args->{dbix_components};
    }
    )
    if (exists($args->{dbix_components}));
}

sub _load_base_commands ($app, $args) {
  # Make <app>::Commands and DCS::Commands available in shell
  push(
    @{$app->commands->namespaces},
    join_class($app->moniker, 'Command'),
    join_class((split($DOUBLE_COLON, __PACKAGE__))[-2], 'Command')
  );
  return $TRUE;
}

sub _load_base_config ($app, $args) {
  $app->plugin(
    'Config::Structured' => {
      config_file => $args->{conf_values} // $ENV{join($UNDERSCORE, uc($app->moniker), 'CONFIG')},
      structure_file => $args->{conf_structure}
    }
  );

  # Configure the application
  $app->secrets($app->conf->secrets);
  return $TRUE;
}

sub _load_base_authentication ($app, $args) {
  $app->plugin('DCS::Authentication');
  return $TRUE;
}

sub _load_base_authorization ($app, $args) {
  return unless (_is_module_loaded('authentication'));
  $app->plugin('DCS::Authorization' => $app->conf->ldap);
  return $TRUE;
}

sub _load_base_datastore ($app, $args) {
  return unless (_is_module_loaded('config'));
  $app->plugin(
    'DCS::DB' => {
      model_class => $args->{model_class} // join_class($app->moniker, 'Model')
    }
  );
  return $TRUE;
}

sub _load_base_session ($app, $args) {
  $app->plugin(
    'DCS::Session' => {
      default_session_expiration => $args->{default_session_expiration},
      admin_roles                => $args->{admin_roles} // [qw(admin)]
    }
  );
  return $TRUE;
}

sub _load_base_openapi ($app, $args) {
  $app->plugin(
    'DCS::API' => {
      api_definition => $args->{api_definition} // $app->home->child('api')->child(lc($app->moniker) . '-api-v1.yml')->to_string,
      security => {
        Password => \&Mojolicious::Plugin::DCS::Authentication::api_password,
        Session  => \&Mojolicious::Plugin::DCS::Authorization::api_session,
      }
    }
  );
  return $TRUE;
}

sub _load_base_vue ($app, $args) {
  $app->plugin('DCS::Vue');
  return $TRUE;
}

sub register ($self, $app, $args) {
  foreach (@features) {
    my ($name, $loader) = each(%{$_});    # only one key-value pair
    push(@loaded, $name);
    if ($loader->($app, $args)) {
      $app->log->debug("DCS::Base loaded '$name'");
    }
  }

  return;
}

sub join_class ($name, @n) {
  return join($DOUBLE_COLON, ucfirst($name), @n);
}

1;

package DCS::Plugin::Config;
use Mojo::Base 'Mojolicious::Plugin';

use DCS::Constants qw(:symbols);

sub register {
  my ($self, $app) = @_;

  $app->helper(
    conf => sub {
      state $config = DCS::Config->new(
         _conf      => do File::Spec->catfile($app->home,join($PERIOD, $app->moniker, $app->mode, qw(conf))),
         _def       => do File::Spec->catfile($app->home,join($PERIOD, $app->moniker, qw(conf def)))
      );
    }
  );
}

package DCS::Config;
use Moose;
use Moose::Util::TypeConstraints;
use Mojo::DynamicMethods -dispatch;

use Carp;
use List::Util qw(reduce);
use Data::DPath qw(dpath);

use DCS::Constants qw(:boolean :symbols);
Readonly::Scalar our $CONF_FROM_ENV   => q(env);
Readonly::Scalar our $CONF_FROM_FILE  => q(conf);

has '_base' => (
  is      => 'ro',
  isa     => 'Str',
  default => '/'
);

has '_def' => (
  is       => 'ro',
  isa      => 'HashRef',
  required => $TRUE
);

has '_conf' => (
  is       => 'ro',
  isa      => 'HashRef',
  required => $TRUE
);

has '_priority' => (
  is      => 'ro',
  isa     => enum([$CONF_FROM_ENV,$CONF_FROM_FILE]),
  default => $CONF_FROM_ENV
);

sub _add_helper {
  Mojo::DynamicMethods::register __PACKAGE__, @_;
}

sub _concat_path {
  reduce { local $/=$SLASH; chomp($a); join(($b =~ m|^$SLASH|) ? $EMPTY : $SLASH, $a, $b) } @_
}

sub BUILD {
  my $self = shift;

  foreach my $el (dpath($self->_base)->match($self->_def)) {
    if(ref($el) eq 'HASH') {
      foreach my $def (keys(%$el)) {
        my $path = _concat_path($self->_base, $def);
        if(exists($el->{$def}->{isa})) {
          # leaf
          my $el = $el->{$def};
          $self->_add_helper($def => sub {
            my @val;
            push(@val, @{dpath($path)->matchr($self->_conf)});
            push(@val, $ENV{$el->{env}}) if(defined($el->{env}));
            @val = grep {defined} @val;

            my $priority = defined($el->{priority}) ? $el->{priority} : $self->_priority;
            return ($priority eq $CONF_FROM_ENV) ? pop(@val) : shift(@val);
          } );
        } else {
          # branch
          $self->_add_helper($def => sub { 
            return __PACKAGE__->new(
              _base     => $path,
              _conf     => $self->_conf,
              _def      => $self->_def,
              _priority => $self->_priority
            ) 
          } );
        }
      }
    }
  }
}

sub BUILD_DYNAMIC {
  my ($class, $method, $dyn_methods) = @_;
  return sub {
    my ($self, @args) = @_;
    my $dynamic = $dyn_methods->{$self}{$method};
    return $self->$dynamic(@args) if($dynamic);
    my $package = ref $self;
    croak qq{Can't locate object method "$method" via package "$package"};
  }
}

1;

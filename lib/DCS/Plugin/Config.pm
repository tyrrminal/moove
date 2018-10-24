package DCS::Plugin::Config;
use Mojo::Base 'Mojolicious::Plugin';

use DCS::Constants qw(:config);

sub register {
  my ($self, $app) = @_;

  $app->helper(
    conf => sub {
      my $home = Mojo::Home->new;
      $home->detect;
      my $f = File::Spec->catfile($home,$app->moniker.".conf");
      state $config = DCS::Config->new(
        _priority => $CONF_FROM_ENV,
        _conf => do $f,
         _def => do "$f.def"
      );
    }
  );
}

package DCS::Config;
use Moose;
use Moose::Util::TypeConstraints;

use Data::DPath qw(dpath);
use DCS::Constants qw(:boolean :config);

has '_base' => (
  is => 'ro',
  isa => 'Str',
  default => ''
);

has '_def' => (
  is => 'ro',
  isa => 'HashRef',
  required => $TRUE
);

has '_conf' => (
  is => 'ro',
  isa => 'HashRef',
  required => $TRUE
);

has '_priority' => (
  is => 'rw',
  isa => enum([$CONF_FROM_ENV,$CONF_FROM_FILE]),
  default => $CONF_FROM_ENV
);

sub AUTOLOAD {
  my ($self, @params) = @_;
  our $AUTOLOAD;
  if($AUTOLOAD =~ /::([[:alpha:]]\w+)$/) {
    my $path = join('/', $self->_base, $1);
    if(my ($el) = @{dpath($path)->matchr($self->_def)}) {
      if(exists($el->{isa})) {
        my @val;
        push(@val, @{dpath($path)->matchr($self->_conf)});
        push(@val, $ENV{$el->{env}}) if(defined($el->{env}));
        @val = grep {defined} @val;

        my $priority = $self->_priority;
        $priority = $el->{priority} if(defined($el->{priority}));
        return ($priority eq $CONF_FROM_ENV) ? pop(@val) : shift(@val);
      } else {
        return __PACKAGE__->new(_conf => $self->_conf, _base => $path, _def => $self->_def, _priority => $self->_priority);
      }
    }
    die(qq{Undefined configuration path "$path"});
  }
  die(qq{Invalid configuration path});
}

1;

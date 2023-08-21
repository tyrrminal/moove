package Moove::Import::Event::Base;
use v5.38;
use builtin qw(true);

use Moose::Role;
use MooseX::ClassAttribute;

use JSON::Validator::Joi qw(joi);

use DCS::Constants                  qw(:symbols);
use Moove::Import::Event::Constants qw(:event);

use experimental qw(builtin);

requires qw(
  url
);

has 'ua' => (
  is       => 'ro',
  isa      => 'Mojo::UserAgent',
  init_arg => undef,
  default  => sub ($class) {Mojo::UserAgent->new},
);

has 'results' => (
  is       => 'ro',
  isa      => 'ArrayRef[HashRef]',
  init_arg => undef,
  lazy     => true,
  builder  => '_build_results',
  traits   => ['Array'],
  handles  => {
    total_entrants => 'count'
  }
);

has 'import_params' => (
  traits   => ['Hash'],
  is       => 'ro',
  isa      => 'HashRef[Int|Str|Undef]',
  required => true,
);

has 'import_param_defaults' => (
  is       => 'ro',
  isa      => 'HashRef[Int|Str|Undef]',
  init_arg => undef,
  writer   => undef,
  builder  => '_build_import_param_defaults'
);

sub _build_import_param_defaults ($self) {
  return {};
}

sub event_id($self) {
  return $self->resolve_field_value('event_id')
}

sub race_id($self) {
  return $self->resolve_field_value('race_id')
}

class_has 'import_param_schemas' => (
  is       => 'ro',
  isa      => 'HashRef[JSON::Validator]',
  init_arg => undef,
  builder  => '_build_import_param_schemas',
  lazy     => true,
);

sub _build_import_param_schemas ($class) {
  return {
    event => JSON::Validator->new()->schema(
      joi->object->strict->props(
        event_id => joi->integer->required,
        )->compile
    ),
    eventactivity => JSON::Validator->new()->schema(
      joi->object->strict->props(
        race_id => joi->string->required,
        )->compile
    )
  };
}

sub import_request_fields ($class) {return []}

has '_import_fields' => (
  is       => 'ro',
  isa      => 'HashRef',
  init_arg => 'import_fields',
  default  => sub {{}}
);

sub import_fields ($self) {
  return {map {$_ => $self->_import_fields->{$_}} $self->import_request_fields->@*};
}

sub resolve_field_value ($self, $name) {
  return $self->_import_fields->{$name}        if (exists($self->_import_fields->{$name}));
  return $self->import_params->{$name}         if (exists($self->import_params->{$name}));
  return $self->import_param_defaults->{$name} if (exists($self->import_param_defaults->{$name}));
  return undef;
}

sub split_names ($self, $v) {
  my @prefixes = qw(del St St. Van De Von O);
  my @suffixes = qw(Jr Jr. Sr Sr. II II. III IV V);
  my $s;
  foreach (@suffixes) {
    if ($v->{name} =~ /\s+\Q$_\E\s*$/i) {
      $v->{name} =~ s/,?\s+\Q$_\E\s*$//i;
      $s = $_;
      last;
    }
  }
  my @parts = split(/\s+/, delete($v->{name}));
  $v->{last_name} = pop(@parts);
  foreach (@prefixes) {
    if (@parts > 1 && $parts[-1] eq $_) {
      $v->{last_name} = join($SPACE, pop(@parts), $v->{last_name});
      last;
    }
  }
  $v->{first_name} = join($SPACE, @parts) || undef;
  $v->{first_name} .= $SPACE . $s if (defined($v->{first_name}) && defined($s));

  $v->{first_name} = $DEFAULT_FIRST_NAME unless (defined($v->{first_name}));
  $v->{last_name}  = $DEFAULT_LAST_NAME  unless (defined($v->{last_name}));
}

1;

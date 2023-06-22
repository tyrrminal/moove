package Moove::Import::Event::Base;
use v5.36;

use Moose::Role;

use builtin      qw(true);
use experimental qw(builtin);

use DCS::Constants qw(:symbols);
use Moove::Import::Event::Constants qw(:event);

requires qw(
  url
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

sub import_request_fields($class) { return [] }

has '_import_fields' => (
  is       => 'ro',
  isa      => 'HashRef',
  init_arg => 'import_fields',
  default  => sub {{}}
);

sub import_fields ($self) {
  return {map { $_ => $self->_import_fields->{$_} } $self->import_request_fields->@*}
}

sub split_names ($self, $v ) {
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

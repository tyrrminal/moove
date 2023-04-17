package Moove::Import::Event::Base;
use v5.36;

use Moose::Role;

use builtin      qw(true);
use experimental qw(builtin);

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

1;

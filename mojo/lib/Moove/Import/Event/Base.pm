package Moove::Import::Event::Base;
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

1;

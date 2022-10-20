package Moove::Import::Event::Constants;
use v5.36;

use base qw(Exporter);

use Readonly;

our @EXPORT_OK = (
  qw(
    $DEFAULT_FIRST_NAME
    $DEFAULT_LAST_NAME
    )
);

our %EXPORT_TAGS = (event => \@EXPORT_OK);

Readonly::Scalar our $DEFAULT_FIRST_NAME => 'Unknown';
Readonly::Scalar our $DEFAULT_LAST_NAME  => 'Unknown';

1;

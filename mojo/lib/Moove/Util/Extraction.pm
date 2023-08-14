package Moove::Util::Extraction;
use v5.38;

use parent 'Exporter';

our @EXPORT_OK = qw(selective_field_extract);

sub selective_field_extract ($hash, $fields) {
  return {map {exists($hash->{$_}) ? ($_ => $hash->{$_}) : ()} $fields->@*};
}

1;

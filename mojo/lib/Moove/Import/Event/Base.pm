package Moove::Import::Event::Base;
use Moose::Role;

requires qw(
  results
  total_entrants
  url
);

1;

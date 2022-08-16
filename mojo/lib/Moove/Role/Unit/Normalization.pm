package Moove::Role::Unit::Normalization;
use v5.36;

use Role::Tiny;

sub normalize_times ($self, $p) {
  foreach (qw(net_time gross_time pace)) {
    if (defined($p->{$_})) {
      unless ($p->{$_} =~ /:\d{2}:/) {    # force times to be h:mm:ss if they're just mm:ss
        $p->{$_} = "0:" . $p->{$_};
      }
    }
  }
}

sub normalize_time ($self, $v) {
  return $v if (!defined($v) || $v =~ /:\d{2}:/);
  return "0:$v";
}

1;

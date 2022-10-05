package Moove::Util::Unit::Normalization;
use v5.36;

use parent 'Exporter';

our @EXPORT_OK = qw(normalize_time normalize_times);

sub normalize_times ($p) {
  foreach (qw(net_time gross_time pace)) {
    if (defined($p->{$_})) {
      unless ($p->{$_} =~ /:\d{2}:/) {    # force times to be h:mm:ss if they're just mm:ss
        $p->{$_} = "0:" . $p->{$_};
      }
    }
  }
}

sub normalize_time ($v) {
  return $v if (!defined($v) || $v =~ /:\d{2}:/);
  return "0:$v";
}

1;

package Moove::Util::Unit::Normalization;
use v5.36;

use parent 'Exporter';

our @EXPORT_OK = qw(normalize_time normalize_times);

use DCS::Constants qw(:symbols);

sub normalize_times ($p) {
  foreach (qw(net_time gross_time pace)) {
    if (defined($p->{$_})) {
      my @nums = split($COLON, $p->{$_});
      unshift(@nums, 0) if (@nums == 2);
      if (@nums == 3) {
        $p->{$_} = join($COLON, map {sprintf('%02d', $_)} @nums);
      } else {
        $p->{$_} = undef;
      }
    }
  }
}

sub normalize_time ($v) {
  return $v if (!defined($v) || $v =~ /:\d{2}:/);
  return "0:$v";
}

1;

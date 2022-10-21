package Moove::Util::Unit::Normalization;
use v5.36;

use parent 'Exporter';

our @EXPORT_OK = qw(normalize_time normalize_times);

sub normalize_times ($p) {
  foreach (qw(net_time gross_time pace)) {
    if (defined($p->{$_})) {
      my $count = $p->{$_} =~ tr/://;
      if ($count == 1) {
        $p->{$_} = "0:" . $p->{$_};
      } elsif ($count != 2) {
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

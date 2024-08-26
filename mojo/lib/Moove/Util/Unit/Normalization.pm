package Moove::Util::Unit::Normalization;
use v5.38;

use parent 'Exporter';

our @EXPORT_OK = qw(normalize_time normalize_times);

use DCS::Constants qw(:symbols);

sub normalize_times ($p) {
  foreach (qw(net_time gross_time pace)) {
    if (defined($p->{$_})) {
      $p->{$_} = normalize_time($p->{$_});
    }
  }
}

sub normalize_time ($v) {
  return $v if (!defined($v) || $v =~ /:\d{2}:/);
  my @c = reverse split(/:/, $v);
  for (my $i = 0 ; $i <= $#c ; $i++) {
    if ($c[$i] > 59) {
      $c[$i + 1] //= int($c[$i] / 60);
      $c[$i] = $c[$i] % 60;
    }
  }
  push(@c, 0)  unless ($#c > 1);
  return undef unless ($#c >= 2);
  return join(':', map {sprintf('%02d', $_)} reverse(@c));
}

1;

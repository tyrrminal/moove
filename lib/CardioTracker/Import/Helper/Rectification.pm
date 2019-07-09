package CardioTracker::Import::Helper::Rectification;
use base qw(Exporter);
use Modern::Perl;

our @EXPORT_OK = qw(normalize_times);

sub normalize_times {
  my $p = shift;

  foreach (qw(net_time gross_time pace)) {
    if (defined($p->{$_})) {
      unless ($p->{$_} =~ /:\d{2}:/) {    # force times to be h:mm:ss if they're just mm:ss
        $p->{$_} = "0:" . $p->{$_};
      }
    }
  }
}

1;

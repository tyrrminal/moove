package CardioTracker::Import::RaceWire;
use Modern::Perl;
use Moose;

sub get_results {
  my $self=shift;
  my ($eid)=@_;

  say "Importing eid $eid";
}

1;

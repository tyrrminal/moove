package Moove::Import::Event::Webscorer;
use v5.38;
use builtin qw(trim);
use Moose;
with 'Moove::Import::Event::Base';

use Mojo::URL;
use Readonly;

use experimental qw(builtin);

Readonly::Scalar my $RESULTS_URL     => 'https://www.webscorer.com/racedetails?raceid=%d&did=%d';
Readonly::Scalar my $RESULTS_API_URL => 'https://www.webscorer.com/racedetails';

Readonly::Hash my %COL_MAP => (
  Place                => 'overall_place',
  Bib                  => 'bib_no',
  Name                 => 'combined_name',
  'First name'         => 'first_name',
  'Last name'          => 'last_name',
  'Team name'          => 'city',
  'Team name 2'        => 'state',
  Category             => 'division',
  Age                  => 'age',
  Gender               => 'gender',
  Time                 => 'gross_time',
  'Pace (time / mile)' => 'pace',
);

has 'heading_map' => (
  is      => 'rw',
  isa     => 'ArrayRef',
  default => sub {[]}
);

sub import_request_fields ($self) {return [qw(viewstate eventvalidation)]}

sub _build_results ($self) {
  my $url = Mojo::URL->new($RESULTS_URL);
  $url->query({raceid => $self->event_id});
  $url->query({did    => $self->race_id});
  my $r = $self->ua->post(
    $url => {Accept => 'text/csv', 'Content-Type' => 'multipart/form-data'} => form => {
      __EVENTTARGET     => 'ctl00$CPH1$RaceLinksButtons1$btnDownloadRaceTxt',
      __VIEWSTATE       => $self->import_fields->{viewstate},
      __EVENTVALIDATION => $self->import_fields->{eventvalidation},
    }
  )->res;

  my @results;
  my $txt = $r->text;
  $txt =~ s/[^[:ascii:]]+//g;
  open(my $FH, '<', \$txt);
  my $headings = <$FH>;
  my @headings = split("\t", $headings);
  my $i;
  for ($i = 0 ; $i < $#headings ; $i++) {
    $headings[$i] = $COL_MAP{$headings[$i]};
  }
  $self->heading_map(\@headings);

  while (my $line = <$FH>) {
    push(@results, $self->make_participant($line));
  }

  return [@results];
}

sub url ($self) {
  return undef unless (defined($RESULTS_URL) && defined($self->event_id) && defined($self->race_id));
  return sprintf($RESULTS_URL, $self->event_id, $self->race_id);
}

sub make_participant ($self, $d) {
  my @fields = split("\t", $d);
  my $p      = {};
  my $i;
  for ($i = 0 ; $i < $#fields ; $i++) {
    my $h = $self->heading_map->[$i];
    $p->{$h} = $fields[$i] if ($h);
  }
  return () if ($p->{gross_time}) eq 'DNS';

  normalize_names($p);
  normalize_gender($p);
  normalize_times($p);

  return $p;
}

sub normalize_gender ($p) {
  $p->{gender} = substr($p->{gender}, 0, 1);
}

sub normalize_names ($p) {
  my @split = split(/\s+/, $p->{combined_name}, 2);
  $p->{first_name} = $split[0] unless (trim($p->{first_name}));
  $p->{last_name}  = $split[1] unless (trim($p->{last_name}));

  $p->{first_name} = ucfirst(lc($p->{first_name})) if ($p->{first_name} !~ /[A-Z]/);
  $p->{last_name}  = ucfirst(lc($p->{last_name}))  if ($p->{last_name}  !~ /[A-Z]/);

  delete($p->{combined_name});
}

sub normalize_times ($p) {
  foreach (qw(gross_time net_time pace)) {
    next unless (exists($p->{$_}));
    next if ($p->{$_} =~ /\d+:\d+:\d+/);
    $p->{$_} = '0:' . $p->{$_};
  }
}

1;

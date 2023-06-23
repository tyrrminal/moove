package Moove::Import::Event::RaceResult;
use v5.36;
use builtin      qw(true);

use Moose;
with 'Moove::Import::Event::Base';

use Readonly;
use Scalar::Util qw(looks_like_number);
use Moove::Util::Unit::Normalization qw(normalize_times);

use experimental qw(builtin);

use DCS::Constants qw(:symbols);
use Moove::Import::Event::Constants qw(:event);

Readonly::Scalar my $metadata_url => 'https://www.secondwindtiming.com/result-page/?id=%s';
Readonly::Scalar my $results_url  => 'https://my2.raceresult.com/%s/RRPublish/data/list';

has 'event_id' => (
  is       => 'ro',
  isa      => 'Str',
  required => true
);

has 'race_id' => (
  is      => 'ro',
  isa     => 'Str',
  default => undef
);

has 'key_map' => (
  traits   => ['Hash'],
  is       => 'ro',
  isa      => 'HashRef[Str]',
  init_arg => undef,
  default  => sub {
    {
      'Bib'        => 'bib_no',
      'Name'       => 'name',
      'Gender'     => 'gender',
      'Club'       => 'city',
      'Group'      => 'division',
      'Place'      => 'overall_place',
      'Group Rank' => 'div_place',
      'Chip Pace'  => 'pace',
      'Chip Time'  => 'net_time'
    };
  },
  handles => {
    get_key => 'get'
  }
);

has 'key_order' => (
  traits   => ['Array'],
  is       => 'rw',
  isa      => 'ArrayRef[Str|Undef]',
  init_arg => undef,
  default  => sub { [undef] },
  handles  => {
    key_name       => 'get',
    key_order_size => 'count'
  }
);

sub url ($self) {
  my ($event_id, $key) = split(/\|/, $self->event_id);
  return sprintf($metadata_url, $event_id);
}

sub _build_results ($self) {
  my ($event_id, $key) = split(/\|/, $self->event_id);
  my ($race_id, $contest_id) = (split(/\|/, $self->race_id),0);

  my $url = Mojo::URL->new(sprintf($results_url, $event_id));
  $url->query(
    key => $key,
    listname => 'Result Lists|Overall Results',
    page => 'results',
    contest => $contest_id,
    r => 'all',
    l => 0
  );


  my $ua  = Mojo::UserAgent->new();
  my $res = $ua->get($url)->result;

  foreach my $f ($res->json->{list}->{Fields}->@*) {
    push($self->key_order->@*, $self->get_key($f->{Label}));
  }

  my $contest_key;
  foreach (keys($res->json->{data}->%*)) {
    $contest_key = $_ and last if(/^#\d+_$race_id$/);
  }
  die("Race contest not found") unless($contest_key);

  my @results = map { $self->make_participant($_) } $res->json->{data}->{$contest_key}->@*;
  
  return [@results];
}

sub make_participant($self, $p) {
  my $participant;
  for my $i (0..$self->key_order_size-1) {
    next unless(defined($self->key_name($i)));
    my $kn = $self->key_name($i);
    my $fn = "_fix_$kn";

    $participant->{$self->key_name($i)} = $self->can($fn) ? $self->$fn($p->[$i]) : $p->[$i];
  }

  $self->_post_fix_city_state($participant);
  $self->_post_fix_div_place($participant);
  $self->split_names($participant);
  normalize_times($participant);

  return $participant
}

sub _fix_overall_place($self, $v) {
  $v =~ s/\D//gr;
}

sub _fix_pace($self, $v) {
  return substr($v, 0, length($v)-length(" min/mile"));
}

sub _post_fix_city_state($self, $p) {
  if($p->{city} =~ /(.*?),\s+([A-Z]{2})/) {
    $p->{city} = $1;
    $p->{'state'} = $2;
  } else {
    delete($p->{city})
  }
}

sub _post_fix_div_place($self, $p) {
  return unless (defined($p->{div_place}));
  if($p->{div_place} eq 'Age Group Champ' || $p->{div_place} eq '1st Overall') {
    $p->{div_place} = 1;
    return;
  }
  my ($place, $count) = split('/', $p->{div_place});
  $p->{div_place} = $place;
  $p->{div_place_count} = $count;
}

1;

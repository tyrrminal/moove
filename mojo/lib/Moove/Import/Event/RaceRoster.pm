package Moove::Import::Event::RaceRoster;
use v5.38;
use Moose;
with 'Moove::Import::Event::Base';

use JSON::Validator::Joi qw(joi);
use DateTime::Format::Strptime;
use Readonly;
use Moove::Util::Unit::Normalization qw(normalize_times);
use Mojo::JSON                       qw(encode_json);

use builtin      qw(true);
use experimental qw(builtin try);

Readonly::Scalar my $RESULTS_PAGE => 'https://results.raceroster.com/en-US/results/%s';
Readonly::Scalar my $RESULTS_URL  => 'https://results.raceroster.com/api/v1/sub-events/%s/locale/en-US/results-column-data';

Readonly::Hash my %QUERY_PARAMS => (
  condensed      => '1',
  time_precision => 'full_second'
);

has '_url' => (
  is       => 'ro',
  isa      => 'Mojo::URL',
  init_arg => undef,
  lazy     => true,
  builder  => '_build_url'
);

has 'result_data' => (
  is       => 'ro',
  isa      => 'HashRef',
  init_arg => undef,
  lazy     => true,
  builder  => '_build_result_data'
);

has 'result_columns' => (
  traits   => ['Array'],
  is       => 'ro',
  isa      => 'ArrayRef[Str]',
  init_arg => undef,
  lazy     => true,
  builder  => '_build_result_columns',
  handles  => {
    'col_count' => 'count'
  }
);

has '_extractors' => (
  traits   => ['Hash'],
  is       => 'ro',
  isa      => 'HashRef[CodeRef]',
  init_arg => undef,
  default  => sub {
    {
      overall_place   => sub ($v) {(overall_place => $v->[1]->{place}, overall_count => $v->[1]->{count})},
      gun_time        => sub ($v) {(gross_time    => $v->[0])},
      chip_time       => sub ($v) {(net_time      => $v->[0])},
      overall_pace    => sub ($v) {(pace          => $v->[1]->{pace})},
      name            => sub ($v) {my @n = split(/\s+/, $v->[1]); return (first_name => $n[0], last_name => $n[1])},
      age             => sub ($v) {(age          => $v->[0])},
      gender          => sub ($v) {(gender       => $v->[1]->{character})},
      bib             => sub ($v) {(bib_no       => $v->[0])},
      from_city       => sub ($v) {(city         => $v->[0])},
      from_prov_state => sub ($v) {(state        => $v->[0])},
      division        => sub ($v) {(division     => $v->[0])},
      gender_place    => sub ($v) {(gender_place => $v->[1]->{place}, gender_count => $v->[1]->{count})},
      division_place  => sub ($v) {(div_place    => $v->[1]->{place}, div_count    => $v->[1]->{count})},
    }
  },
  handles => {
    extractor => 'get'
  }
);

sub _build_url ($self) {
  my $md = Mojo::URL->new(sprintf($RESULTS_URL, $self->event_id));
  return $md->query(%QUERY_PARAMS);
}

sub _build_result_data ($self) {
  my $ua  = Mojo::UserAgent->new();
  my $res = $ua->get($self->_url => {Accept => 'application/json'})->result;

  return $res->json->{data};
}

sub _build_result_columns ($self) {
  [map {$_->{id}} $self->result_data->{results}->{columns}->@*];
}

sub url ($self) {
  return undef unless (defined($self->race_id));
  return sprintf($RESULTS_PAGE, $self->race_id);
}

sub _build_results ($self) {
  return [map {$self->make_participant($_)} $self->result_data->{results}->{data}->@*];
}

sub make_participant ($self, $d) {
  my $p = {};
  for (my $i = 0 ; $i < $self->col_count ; $i++) {
    my %v;
    try {
      %v = $self->extractor($self->result_columns->[$i])->($d->[$i + 1]);
    } catch ($e) {
      chomp($e);
      say STDERR "Extraction error occurred in colum $i: '$e' on '" . encode_json($d) . "'";
    }
    $p = {$p->%*, %v};
  }
  normalize_times($p);
  return $p;
}

1;

package Moove::Import::Event::RaceRoster;
use v5.36;

use Moose;

use Role::Tiny::With;
with 'Moove::Role::Unit::Normalization';

use DateTime::Format::Strptime;
use Readonly;

use experimental qw(builtin);

Readonly::Scalar my $RESULTS_PAGE => 'https://results.raceroster.com/en-US/results/%s';
Readonly::Scalar my $RESULTS_URL  => 'https://results.raceroster.com/api/v1/sub-events/%s/locale/en-US/results-column-data';

Readonly::Hash my %QUERY_PARAMS => (
  condensed      => '1',
  time_precision => 'full_second'
);

has 'event_id' => (
  is       => 'ro',
  isa      => 'Str',
  required => builtin::true
);

has 'race_id' => (
  is      => 'ro',
  isa     => 'Str|Undef',
  default => undef
);

has '_url' => (
  is       => 'ro',
  isa      => 'Mojo::URL',
  init_arg => undef,
  lazy     => builtin::true,
  builder  => '_build_url'
);

has 'result_data' => (
  is       => 'ro',
  isa      => 'HashRef',
  init_arg => undef,
  lazy     => builtin::true,
  builder  => '_build_result_data'
);

has 'result_columns' => (
  traits   => ['Array'],
  is       => 'ro',
  isa      => 'ArrayRef[Str]',
  init_arg => undef,
  lazy     => builtin::true,
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
  my $res = $ua->get($self->_url)->result;

  return $res->json->{data};
}

sub _build_result_columns ($self) {
  [map {$_->{id}} $self->result_data->{results}->{columns}->@*];
}

sub url ($self) {
  return sprintf($RESULTS_PAGE, $self->race_id);
}

sub find_and_update_event ($self, $rs) {
  my $event = $rs->search(
    {
      ref_num     => $self->event_id,
      description => 'RaceRoster'
    }, {
      join => {event_references => 'event_reference_type'}
    }
  )->first;

  $event->update(
    {
      entrants => $self->result_data->{results}->{quantity}
    }
  );

  return $event;
}

sub fetch_results ($self) {
  return map {$self->make_participant($_)} $self->result_data->{results}->{data}->@*;
}

sub make_participant ($self, $d) {
  my $p = {};
  for (my $i = 0 ; $i < $self->col_count ; $i++) {
    my %v = $self->extractor($self->result_columns->[$i])->($d->[$i + 1]);
    $p = {$p->%*, %v};
  }
  return $p;
}

1;

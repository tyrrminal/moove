package Moove::Import::Event::RealTimeRaceTracking;
use v5.38;
use Moose;
with 'Moove::Import::Event::Base';

use JSON::Validator::Joi qw(joi);
use DateTime::Format::Strptime;
use Readonly;
use Moove::Util::Unit::Normalization qw(normalize_times);
use Moove::Import::Helper::CityService;
use Mojo::JSON qw(encode_json);

use builtin      qw(true false);
use experimental qw(builtin try);

Readonly::Scalar my $RESULTS_PAGE => 'https://track.rtrt.me/e/%s#/';
Readonly::Scalar my $RESULTS_URL  => 'https://api.rtrt.me/events/%s/places/course/%s';

sub import_request_fields ($self) {return [qw(appid token)]}

has '_url' => (
  is       => 'ro',
  isa      => 'Mojo::URL',
  init_arg => undef,
  lazy     => true,
  builder  => '_build_url'
);

has 'city_service' => (
  is       => 'ro',
  isa      => 'Moove::Import::Helper::CityService',
  init_arg => undef,
  lazy     => true,
  default  => sub {Moove::Import::Helper::CityService->new()},
);

has '_fields' => (
  traits   => ['Hash'],
  is       => 'ro',
  isa      => 'HashRef[CodeRef]',
  init_arg => undef,
  default  => sub {
    {
      age           => sub ($v) {undef},
      bib_no        => sub ($v) {$v->{bib}},
      city          => sub ($v) {$v->{city}},
      country       => sub ($v) {$v->{country}},
      div_place     => sub ($v) {$v->{results}->{agegroup}->{p}},
      division      => sub ($v) {$v->{results}->{agegroup}->{n}},
      first_name    => sub ($v) {my ($fn, $ln) = $v->{name} =~ /^(.*)\s+(\S+)$/; $fn},
      gender        => sub ($v) {$v->{sex}},
      gender_place  => sub ($v) {$v->{results}->{gender}->{p}},
      gross_time    => sub ($v) {$v->{waveTime}},
      last_name     => sub ($v) {my ($fn, $ln) = $v->{name} =~ /^(.*)\s+(\S+)$/; $ln},
      net_time      => sub ($v) {$v->{netTime}},
      overall_place => sub ($v) {$v->{results}->{course}->{p}},
      pace          => sub ($v) {$v->{milePaceAvg}},
      'state'       => sub ($v) {undef}
    }
  },
  handles => {
    fields    => 'keys',
    extractor => 'get'
  }
);

sub _build_import_param_schemas ($class) {
  return {
    event => JSON::Validator->new()->schema(
      joi->object->strict->props(
        event_id => joi->string->required,
      )
    ),
    eventactivity => JSON::Validator->new()->schema(
      joi->object->strict->props(
        race_id => joi->string->required,
      )
    )
  };
}

sub _build_url ($self) {
  return Mojo::URL->new(sprintf($RESULTS_URL, $self->event_id, $self->race_id));
}

sub _build_results ($self) {
  my ($page, @results) = (1);
  while (true) {
    my $res = $self->fetch_results($page++);

    my @records = ($res->json->{list} // [])->@*;
    last unless (@records);
    foreach my $r (@records) {
      my $p = $self->make_participant($r);
      push(@results, $p);
    }
  }
  return [@results];
}

sub fetch_results ($self, $page = 1) {
  my $size = 50;
  my $ua   = Mojo::UserAgent->new();
  my $res  = $ua->post($self->_url => $self->headers => form => {$self->body->%*, start => ($page - 1) * $size + 1, max => $size});
  return $res->result;
}

sub headers ($self) {
  return {
    Accept         => 'application/json',
    'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
    'User-Agent'   => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/111.0'
  };
}

sub body ($self) {
  return {
    event             => $self->event_id,
    sess              => 0,
    'combo[division]' => 'runner',
    source            => 'webtracker',
    $self->import_fields->%*,
  };
}

sub url ($self) {
  return undef unless (defined($self->race_id));
  return sprintf($RESULTS_PAGE, $self->race_id);
}

sub make_participant ($self, $d) {
  my $p = {map {$_ => $self->extractor($_)->($d)} $self->fields};

  # Add state if possible
  if (defined($p->{country}) && defined($p->{city}) && $p->{country} eq 'USA') {
    my @combos = $self->city_service->combos_with_city($p->{city});
    $p->{'state'} = $combos[0]->{state_abbrv} if (@combos == 1);
  }

  # Fix anonymous records
  if ($d->{name} eq 'anonymous') {
    $p->{first_name} = 'anon';
    $p->{last_name}  = 'anon';
  }
  if (!defined($p->{bib_no})) {
    $p->{bib_no} = 'NB_' . $p->{overall_place};
  }

  # Fix times
  normalize_times($p);

  return $p;
}

1;

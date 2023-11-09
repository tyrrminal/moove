package Moove::Import::Event::RealTimeRaceTracking;
use v5.38;
use Moose;
with 'Moove::Import::Event::Base';

use JSON::Validator::Joi qw(joi);
use DateTime::Format::Strptime;
use Readonly;
use List::MoreUtils                  qw(firstidx);
use Moove::Util::Unit::Normalization qw(normalize_times);
use Moove::Import::Helper::CityService;
use Mojo::JSON qw(encode_json);

use builtin      qw(true false);
use experimental qw(builtin try);

use DCS::Constants qw(:symbols);

Readonly::Scalar my $RESULTS_PAGE     => 'https://track.rtrt.me/e/%s#/';
Readonly::Scalar my $RESULTS_BASE_URL => 'https://api.rtrt.me/events/%s/';

sub import_request_fields ($self) {return [qw(appid token)]}

has 'city_service' => (
  is       => 'ro',
  isa      => 'Moove::Import::Helper::CityService',
  init_arg => undef,
  lazy     => true,
  default  => sub {Moove::Import::Helper::CityService->new()},
);

sub _build_import_param_schemas ($class) {
  return {
    event => JSON::Validator->new()->schema(
      joi->object->strict->props(
        event_id => joi->string->required,
        )->compile
    ),
    eventactivity => JSON::Validator->new()->schema(
      joi->object->strict->props(
        race_id => joi->string->required,
        point   => joi->string
        )->compile
    )
  };
}

sub _build_import_param_defaults ($self) {
  return {point => 'FINISH'};
}

sub _build_results ($self) {
  my $headers = {
    'Accept'       => 'application/json',
    'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
  };

  my $list =
    [grep {!exists($_->{undefined})}
      $self->ua->post(sprintf($RESULTS_BASE_URL, $self->event_id) . 'places' => $headers => form => $self->import_fields)
      ->result->json->{list}->@*];
  my $place_item  = _placement_list_extract($list, 'label', 'Overall');
  my $place       = $place_item->{name};
  my $results_map = {
    division => _placement_list_extract($list, 'fields', [qw(division sex agegroup)])->{name},
    gender   => _placement_list_extract($list, 'fields', [qw(division sex)])->{name},
    overall  => $place_item->{name},
  };

  my $url  = join($SLASH, sprintf($RESULTS_BASE_URL, $self->event_id) . 'places', $place, $self->race_id);
  my $body = {
    $self->import_fields->%*,
    event  => $self->event_id,
    source => 'webtracker',
    sess   => 0,
    map {sprintf('combo[%s]', $_) => $self->resolve_field_value($_)} ($place_item->{fields}->@*)
  };

  my $fetch_results = sub ($page = 1) {
    my $size = 50;
    my $res  = $self->ua->post($url => $headers => form => {$body->%*, start => ($page - 1) * $size + 1, max => $size});
    return $res->result;
  };

  my ($page, @results) = (1);
  while (true) {
    my $res = $fetch_results->($page++);

    my @records = ($res->json->{list} // [])->@*;
    last unless (@records);
    foreach my $r (@records) {
      my $p = $self->make_participant($r, $results_map);
      push(@results, $p);
    }
  }
  return [@results];
}

sub url ($self) {
  return undef unless (defined($self->race_id));
  return sprintf($RESULTS_PAGE, $self->race_id);
}

sub make_participant ($self, $d, $results_map) {
  my $fields = {
    bib_no => sub ($v) {$v->{bib}},
    age    => sub ($v) {undef},
    gender => sub ($v) {$v->{sex}},

    gross_time => sub ($v) {$v->{waveTime}},
    net_time   => sub ($v) {$v->{netTime}},
    pace       => sub ($v) {$v->{milePaceAvg}},

    division      => sub ($v) {$v->{results}->{$results_map->{division}}->{n}},
    div_place     => sub ($v) {$v->{results}->{$results_map->{division}}->{p}},
    gender_place  => sub ($v) {$v->{results}->{$results_map->{gender}}->{p}},
    overall_place => sub ($v) {$v->{place}},

    first_name => sub ($v) {my ($fn, $ln) = $v->{name} =~ /^(.*)\s+(\S+)$/; $fn},
    last_name  => sub ($v) {my ($fn, $ln) = $v->{name} =~ /^(.*)\s+(\S+)$/; $ln},
    city       => sub ($v) {$v->{city}},
    country    => sub ($v) {$v->{country}},
    'state'    => sub ($v) {undef}
  };

  my $p = {map {$_ => $fields->{$_}->($d)} keys($fields->%*)};

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

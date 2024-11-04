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
use Moove::Import::Helper::ZipCodeService;
use Mojo::JSON qw(encode_json);

use builtin      qw(true false trim);
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

has 'zipcode_service' => (
  is       => 'ro',
  isa      => 'Moove::Import::Helper::ZipCodeService',
  init_arg => undef,
  lazy     => true,
  builder  => '_build_zipservice'
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

sub _build_zipservice ($self) {
  Moove::Import::Helper::ZipCodeService->new(api_key => $self->keys->{zip});
}

sub _build_results ($self) {
  my $headers = {
    'Accept'       => 'application/json',
    'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
  };

  my $base = sprintf($RESULTS_BASE_URL, $self->event_id);

  my $conf = $self->ua->post(
    $base
      . 'conf' => $headers => form => {
      source => 'webtracker',
      $self->import_fields->%*,
      }
  )->result->json;
  my ($reg) = grep {$_->{race} eq $self->race_id} $conf->{conf}->{skus}->{reg}->@*;
  my @categories = grep {
    $_->{course} eq $reg->{course}     # filter out categories for other races
      && $_->{title} !~ /Residents/    # exclude "Falmouth Residents" categories
      && $_->{publish}                 # exclude unpublished categories
      && $_->{lboard}                  # exclude non-leaderboard categories
      && $_->{loadmore}                # exclude top finishers categories
      && $_->{netscore}                # ???
  } $conf->{conf}->{categories}->@*;
  foreach my $cat (@categories) {
    $cat->{$_} = $cat->{$_} // q{} for (qw(name title subtitle));
    if ($cat->{name} =~ /(fe)?male.*agegroup.*:_ALL$/ || $cat->{subtitle} =~ /^[FMUX]$/) {
      $cat->{place_key} = 'gender_place';
    } elsif ($cat->{subtitle} eq 'Overall' || $cat->{subtitle} eq q{}) {
      $cat->{place_key} = 'overall_place';
    } else {
      $cat->{place_key} = 'div_place';
    }
  }

  my %p;
  foreach my $cat (@categories) {
    my $url = join($SLASH, $base . 'categories', $cat->{name}, 'splits', $self->resolve_field_value('point'));
    my ($start, $max, $size) = (1, 100);
    do {
      my $list = $self->ua->post(
        $url => $headers => form => {
          units  => 'standard',
          source => 'webtracker',
          start  => $start,
          max    => $max,
          $self->import_fields->%*,
        }
      )->result->json->{list};
      last unless (defined($list));
      $size = $list->@*;
      foreach my $cat_p ($list->@*) {
        my $place = delete($cat_p->{place});
        $p{$cat_p->{pid}}                      = $cat_p unless (defined($p{$cat_p->{pid}}));
        $p{$cat_p->{pid}}->{$cat->{place_key}} = $place;
        $p{$cat_p->{pid}}->{division}          = join(" ", $cat->{title} // '', $cat->{subtitle} // '') =~ s/\s+/ /gr
          if ($cat->{place_key} eq 'div_place');
      }
      $start += $max;
    } until ($size < $max);
  }

  my @results = map {$self->make_participant($_)} values(%p);
  return [@results];
}

sub url ($self) {
  return undef unless (defined($self->event_id));
  return sprintf($RESULTS_PAGE, $self->event_id);
}

sub make_participant ($self, $d) {
  my $fields = {
    bib_no => sub ($v) {$v->{bib}},
    age    => sub ($v) {undef},
    gender => sub ($v) {$v->{sex}},

    gross_time => sub ($v) {$v->{waveTime}},
    net_time   => sub ($v) {$v->{netTime}},
    pace       => sub ($v) {$v->{milePaceAvg}},

    division      => sub ($v) {$v->{division}},
    div_place     => sub ($v) {$v->{div_place}},
    gender_place  => sub ($v) {$v->{gender_place}},
    overall_place => sub ($v) {$v->{overall_place}},

    first_name => sub ($v) {my ($fn, $ln) = $v->{name} =~ /^(.*)\s+(\S+)$/; $fn},
    last_name  => sub ($v) {my ($fn, $ln) = $v->{name} =~ /^(.*)\s+(\S+)$/; $ln},
    city       => sub ($v) {$v->{city}},
    country    => sub ($v) {$v->{country}},
    'state'    => sub ($v) {undef}
  };

  my $p = {map {$_ => $fields->{$_}->($d)} keys($fields->%*)};

  # Add state if possible
  if (defined($p->{city}) && $p->{city} =~ /(\d{5})(-\d{4})?$/) {
    my @combos = $self->zipcode_service->zip_lookup($1);
    if (@combos) {
      $p->{city}    = $combos[0]->{city};
      $p->{'state'} = $combos[0]->{state_code};
    } else {
      $p->{city} = undef;
    }
  } elsif (defined($p->{country}) && defined($p->{city}) && $p->{country} eq 'USA') {
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

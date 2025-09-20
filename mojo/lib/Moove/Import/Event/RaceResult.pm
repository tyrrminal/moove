package Moove::Import::Event::RaceResult;
use v5.38;
use builtin qw(true);

use Moose;
with 'Moove::Import::Event::Base';

use JSON::Validator::Joi qw(joi);
use Readonly;
use Scalar::Util                     qw(looks_like_number);
use Moove::Util::Unit::Normalization qw(normalize_times);

use experimental qw(builtin);

use DCS::Constants                  qw(:symbols);
use Moove::Import::Event::Constants qw(:key_fields);
use Moove::Import::Event::Constants qw(:event);

Readonly::Scalar my $METADATA_URL => 'https://www.secondwindtiming.com/result-page/?id=%s';
Readonly::Scalar my $RESULTS_URL  => 'https://my2.raceresult.com/%s/RRPublish/data/list';

has 'key_map' => (
  traits   => ['Hash'],
  is       => 'ro',
  isa      => 'HashRef[Str|Undef]',
  init_arg => undef,
  default  => sub {
    {
      'Overall'   => $OVERALL_PLACE,
      'Name'      => $FULL_NAME,
      'BIB'       => $BIB_NUMBER,
      'Time'      => $NET_TIME,
      'Pace'      => $PACE,
      'Sex'       => $GENDER,
      'By Sex'    => $GENDER_PLACE,
      'By Age'    => $DIVISION_PLACE,
      'Age Group' => $DIVISION,
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
  default  => sub {[]},
  handles  => {
    key_name       => 'get',
    key_order_size => 'count'
  }
);

sub _build_import_param_schemas ($self) {
  return {
    event => JSON::Validator->new()->schema(
      joi->object->strict->props(
        event_id   => joi->integer->required->min(1),
        import_key => joi->string->required->min(1),
        )->compile,
    ),
    eventactivity => JSON::Validator->new()->schema(
      joi->object->strict->props(
        race_id       => joi->string->min(1),
        contest_id    => joi->integer->required->min(0),
        list_category => joi->string,
        listname      => joi->string->required->min(1),
        )->compile
    )
  };
}

sub url ($self) {
  return undef unless (defined($self->event_id));
  return sprintf($METADATA_URL, $self->event_id);
}

sub _build_results ($self) {
  my $url = Mojo::URL->new(sprintf($RESULTS_URL, $self->event_id));
  $url->query(
    key      => $self->import_params->{import_key},
    listname => join($PIPE, ($self->import_params->{list_category} // 'Result Lists'), $self->import_params->{listname}),
    page     => 'results',
    contest  => $self->import_params->{contest_id},
    r        => 'all',
    l        => 0
  );

  my $res = $self->ua->get($url)->result;

  foreach my $df ($res->json->{DataFields}->@*) {
    my ($f) = grep {$_->{Expression} eq $df} $res->json->{list}->{Fields}->@*;
    push($self->key_order->@*, (defined($f) ? $self->get_key($f->{Label}) : undef));
  }

  my $data;
  if (ref($res->json->{data}) eq 'ARRAY') {
    $data = $res->json->{data};
  } else {
    my $race_id = $self->race_id;
    my $contest_key;
    foreach (keys($res->json->{data}->%*)) {
      $contest_key = $_ and last if (/^#\d+_$race_id$/);
    }
    die("Race contest not found") unless ($contest_key);
    $data = $res->json->{data}->{$contest_key};
  }

  my @results = map {$self->make_participant($_)} $data->@*;

  return [@results];
}

sub make_participant ($self, $p) {
  my $participant;
  for my $i (0 .. $self->key_order_size - 1) {
    next unless (defined($self->key_name($i)));
    my $kn = $self->key_name($i);
    my $fn = "_fix_$kn";

    $participant->{$kn} = $self->can($fn) ? $self->$fn($p->[$i]) : $p->[$i];
  }

  $self->_post_fix_city_state($participant);
  $self->_post_fix_gender_place($participant);
  $self->_post_fix_div_place($participant);
  $self->split_names($participant);
  normalize_times($participant);

  return $participant;
}

sub _fix_overall_place ($self, $v) {
  $v =~ s/\D//gr;
}

sub _fix_pace ($self, $v) {
  $v =~ s/[^0-9:]//gr;
}

sub _post_fix_city_state ($self, $p) {
  return unless (defined($p->{$CITY}));
  if ($p->{$CITY} =~ /(.*?),\s+([A-Z]{2})/) {
    $p->{$CITY}  = $1;
    $p->{$STATE} = $2;
  } else {
    delete($p->{$CITY});
  }
}

sub _post_fix_gender_place ($self, $p) {
  return unless (defined($p->{$GENDER_PLACE}));
  if ($p->{$GENDER_PLACE} =~ /^(\d+)\w+ Overall$/) {
    $p->{$GENDER_PLACE} = $1;
    return;
  }
  my ($place, $count) = split('/', $p->{$GENDER_PLACE});
  $p->{$GENDER_PLACE}       = $place;
  $p->{$GENDER_PLACE_COUNT} = $count;
}

sub _post_fix_div_place ($self, $p) {
  return unless (defined($p->{$DIVISION_PLACE}));
  if ($p->{$DIVISION_PLACE} eq 'Age Group Champ') {
    $p->{$DIVISION_PLACE} = 1;
    return;
  }
  if ($p->{$DIVISION_PLACE} =~ /^(\d+)\w+ Overall$/) {
    $p->{$DIVISION_PLACE} = $1;
    return;
  }
  my ($place, $count) = split('/', $p->{$DIVISION_PLACE});
  $p->{$DIVISION_PLACE}       = $place;
  $p->{$DIVISION_PLACE_COUNT} = $count;

  $p->{$DIVISION_PLACE}       = undef unless (looks_like_number($p->{$DIVISION_PLACE}));
  $p->{$DIVISION_PLACE_COUNT} = undef unless (looks_like_number($p->{$DIVISION_PLACE_COUNT}));
}

1;

__END__

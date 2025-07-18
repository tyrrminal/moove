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
use Moove::Import::Event::Constants qw(:event);

Readonly::Scalar my $METADATA_URL => 'https://www.secondwindtiming.com/result-page/?id=%s';
Readonly::Scalar my $RESULTS_URL  => 'https://my2.raceresult.com/%s/RRPublish/data/list';

has 'key_map' => (
  traits   => ['Hash'],
  is       => 'ro',
  isa      => 'HashRef[Str]',
  init_arg => undef,
  default  => sub {
    {
      'BIB'                             => 'bib_no',
      'Bib'                             => 'bib_no',
      'Name'                            => 'name',
      'DisplayName'                     => 'name',
      'DisplayName_Public'              => 'name',
      'Sex'                             => 'gender',
      'Gender'                          => 'gender',
      'GenderMF'                        => 'gender',
      'Club'                            => 'city',
      'ClubOrCity'                      => 'city',
      'Age Group'                       => 'division',
      'AgeGroupPostRace'                => 'division_place',
      'Group'                           => 'division',
      'division'                        => 'division',
      'Overall'                         => 'overall_place',
      'Place'                           => 'overall_place',
      'WithStatus([OverallRankp])'      => 'overall_place',
      'WithStatus([OverallRank_Chipp])' => 'overall_place',
      'By Sex'                          => 'gender_place',
      'Group Rank'                      => 'div_place',
      'By Age'                          => 'div_place',
      'Pace'                            => 'pace',
      'Chip Pace'                       => 'pace',
      'Finish.CHIP.SPEEDORPACE'         => 'pace',
      'Finish.SPEEDORPACE'              => 'pace',
      'Time'                            => 'net_time',
      'Chip Time'                       => 'net_time',
      'Finish.CHIP'                     => 'net_time',
      'Finish.GUN'                      => 'gross_time',
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

  if (exists($res->json->{DataFields})) {
    push($self->key_order->@*, $self->get_key($_)) foreach ($res->json->{DataFields}->@*);
  } else {
    push($self->key_order->@*, undef);
    push($self->key_order->@*, $self->get_key($_->{Label})) foreach ($res->json->{list}->{Fields}->@*);
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

    $participant->{$self->key_name($i)} = $self->can($fn) ? $self->$fn($p->[$i]) : $p->[$i];
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
  return substr($v, 0, length($v) - length(" min/mile"));
}

sub _post_fix_city_state ($self, $p) {
  return unless (defined($p->{city}));
  if ($p->{city} =~ /(.*?),\s+([A-Z]{2})/) {
    $p->{city}    = $1;
    $p->{'state'} = $2;
  } else {
    delete($p->{city});
  }
}

sub _post_fix_gender_place ($self, $p) {
  return unless (defined($p->{gender_place}));
  if ($p->{gender_place} =~ /^(\d+)\w+ Overall$/) {
    $p->{gender_place} = $1;
    return;
  }
  my ($place, $count) = split('/', $p->{gender_place});
  $p->{gender_place}       = $place;
  $p->{gender_place_count} = $count;
}

sub _post_fix_div_place ($self, $p) {
  return unless (defined($p->{div_place}));
  if ($p->{div_place} eq 'Age Group Champ') {
    $p->{div_place} = 1;
    return;
  }
  if ($p->{div_place} =~ /^(\d+)\w+ Overall$/) {
    $p->{div_place} = $1;
    return;
  }
  my ($place, $count) = split('/', $p->{div_place});
  $p->{div_place}       = $place;
  $p->{div_place_count} = $count;
}

1;

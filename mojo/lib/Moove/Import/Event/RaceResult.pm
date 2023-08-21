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
  default  => sub {[undef]},
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
        race_id    => joi->string->required->min(1),
        contest_id => joi->integer->required->min(1),
        listname   => joi->string->required->min(1),
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
    listname => join($PIPE, 'Result Lists', $self->import_params->{listname}),
    page     => 'results',
    contest  => $self->import_params->{contest_id},
    r        => 'all',
    l        => 0
  );


  my $ua  = Mojo::UserAgent->new();
  my $res = $ua->get($url)->result;

  foreach my $f ($res->json->{list}->{Fields}->@*) {
    push($self->key_order->@*, $self->get_key($f->{Label}));
  }

  my $race_id = $self->race_id;
  my $contest_key;
  foreach (keys($res->json->{data}->%*)) {
    $contest_key = $_ and last if (/^#\d+_$race_id$/);
  }
  die("Race contest not found") unless ($contest_key);

  my @results = map {$self->make_participant($_)} $res->json->{data}->{$contest_key}->@*;

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
  if ($p->{city} =~ /(.*?),\s+([A-Z]{2})/) {
    $p->{city}    = $1;
    $p->{'state'} = $2;
  } else {
    delete($p->{city});
  }
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

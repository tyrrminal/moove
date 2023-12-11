package Moove::Import::Event::RunSignup;
use v5.38;
use Moose;
with 'Moove::Import::Event::Base';

use JSON::Validator::Joi qw(joi);
use Readonly;
use Moove::Util::Unit::Normalization qw(normalize_times);

use DCS::Constants qw(:symbols);

use builtin      qw(true);
use experimental qw(builtin);

# https://runsignup.com/Race/Results/98582#resultSetId-350160;perpage:100

Readonly::Scalar my $PER_PAGE => 100;

Readonly::Scalar my $RESULTS_URL     => 'https://runsignup.com/Race/Results/%s#resultSetId-%s;perpage:100';
Readonly::Scalar my $RESULTS_API_URL => 'https://runsignup.com/Race/Results/%s';
# ?resultSetId=350160&page=1&num=100&search=';

Readonly::Scalar my $MODE_COMBINED_GENDER_DIVISION => 1;
Readonly::Scalar my $MODE_SEPARATE_GENDER_DIVISION => 2;

has 'key_map' => (
  traits   => ['Hash'],
  is       => 'ro',
  isa      => 'HashRef[Str]',
  init_arg => undef,
  lazy     => true,
  builder  => '_build_key_map',
  handles  => {
    get_key => 'get'
  }
);

has 'record_key_map' => (
  traits   => ['Array'],
  is       => 'rw',
  isa      => 'ArrayRef[Str]',
  init_arg => undef,
  default  => sub {[]},
  handles  => {
    get_record_key => 'get'
  }
);

sub _build_key_map ($self) {
  my $m = {
    bib_num        => 'bib_no',
    city           => 'city',
    gender         => 'gender',
    chip_time      => 'net_time',
    clock_time     => 'gross_time',
    race_placement => 'overall_place',
    'state'        => 'state',
    avg_pace       => 'pace',
    name           => 'combined_name',
  };

  if ($self->import_mode == $MODE_COMBINED_GENDER_DIVISION) {
    $m->{division_place} = 'genderdivision_place';
    $m->{division}       = 'genderdivision_group';
    $m->{name}           = 'combined_name';
  } elsif ($self->import_mode == $MODE_SEPARATE_GENDER_DIVISION) {
    $m->{division_place} = 'div_place';
    $m->{division}       = 'division';
    $m->{'Gender Place'} = 'gender_place';
  }
  return $m;
}

sub _build_results ($self) {
  my $page = 1;
  my $res  = $self->fetch_results($page);

  my $headings = $res->json->{headings};
  $self->record_key_map([map {$self->get_key($_->{key}) // $self->get_key($_->{name}) // $EMPTY} $headings->@*]);

  my @results;
  do {
    my @resultset = $res->json->{resultSet}->{results}->@*;
    foreach my $i (0 .. $#resultset) {
      my $p = $self->make_participant_record($resultset[$i]->@*);
      split_names($p, $res->json->{auxData}->{rowFirstNameLens}->[$i]);
      separate_division_groups($p) if ($self->import_mode == $MODE_COMBINED_GENDER_DIVISION);
      normalize_times($p);
      push(@results, $p);
    }

    $res = $self->fetch_results(++$page);
  } while ($res->json->{resultSet}->{results}->@*);

  return [@results];
}

sub _build_import_param_schemas ($class) {
  return {
    event => JSON::Validator->new()->schema(
      joi->object->strict->props(
        event_id => joi->integer->required,
        )->compile
    ),
    eventactivity => JSON::Validator->new()->schema(
      joi->object->strict->props(
        race_id                  => joi->string->required,
        segment_id               => joi->string,
        custom_class             => joi->string,
        combined_gender_division => joi->boolean,
        )->compile
    )
  };
}

sub import_mode ($self) {
  my $m = undef;
  if ($self->resolve_field_value('combined_gender_division')) {
    $m = $MODE_COMBINED_GENDER_DIVISION;
  } else {
    $m = $MODE_SEPARATE_GENDER_DIVISION;
  }
  return $m;
}

sub make_participant_record ($self, @fields) {
  my %record = map {$self->get_record_key($_) => $fields[$_]} (0 .. $#fields);
  delete($record{$EMPTY});
  return {%record};
}

sub fetch_results ($self, $page = 1) {
  my $url = Mojo::URL->new(sprintf($RESULTS_API_URL, $self->event_id));
  $url->query(resultSetId => $self->race_id, page => $page, num => $PER_PAGE, search => $EMPTY);

  return $self->ua->get($url => {Accept => 'application/json'})->result;
}

sub url ($self) {
  return undef unless (defined($RESULTS_URL) && defined($self->event_id) && defined($self->race_id));
  return sprintf($RESULTS_URL, $self->event_id, $self->race_id);
}

sub split_names ($record, $first_name_length) {
  my $name = delete($record->{combined_name});
  $record->{first_name} = substr($name, 0, $first_name_length);
  $record->{last_name}  = substr($name, $first_name_length + 1);
}

sub separate_division_groups ($record) {
  my @combined_group = split($NEWLINE, delete($record->{genderdivision_group}));
  my @combined_place = split($NEWLINE, delete($record->{genderdivision_place}));

  $record->{gender_place} = $combined_place[0];
  $record->{div_place}    = $combined_place[1];
  $record->{division}     = $combined_group[1];
}

1;

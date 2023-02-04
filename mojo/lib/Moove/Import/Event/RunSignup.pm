package Moove::Import::Event::RunSignup;
use v5.36;
use Moose;
with 'Moove::Import::Event::Base';

use Readonly;
use Moove::Util::Unit::Normalization qw(normalize_times);

use DCS::Constants qw(:symbols);

use builtin      qw(true);
use experimental qw(builtin);

# https://runsignup.com/Race/Results/98582#resultSetId-350160;perpage:100

Readonly::Scalar my $per_page => 100;

Readonly::Scalar my $results_url     => 'https://runsignup.com/Race/Results/%s#resultSetId-%s;perpage:100';
Readonly::Scalar my $results_api_url => 'https://runsignup.com/Race/Results/%s';
# ?resultSetId=350160&page=1&num=100&search=';

has 'event_id' => (
  is       => 'ro',
  isa      => 'Str',
  required => true
);

has 'race_id' => (
  is       => 'ro',
  isa      => 'Str',
  required => true,
);

has 'key_map' => (
  traits   => ['Hash'],
  is       => 'ro',
  isa      => 'HashRef[Str]',
  init_arg => undef,
  default  => sub {
    {
      'bib_num'        => 'bib_no',
      'city'           => 'city',
      'gender'         => 'gender',
      'chip_time'      => 'net_time',
      'clock_time'     => 'gross_time',
      'race_placement' => 'overall_place',
      'state'          => 'state',
      'avg_pace'       => 'pace',

      'division_place' => 'genderdivision_place',
      'division'       => 'genderdivision_group',
      'name'           => 'combined_name',
    };
  },
  handles => {
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

use Data::Printer;
sub _build_results ($self) {
  my $page = 1;
  my $res  = $self->fetch_results($page);

  my $headings = $res->json->{headings};
  $self->record_key_map([map {$self->get_key($_->{key}) // $EMPTY} $headings->@*]);

  my @results;
  do {
    my @resultset = $res->json->{resultSet}->{results}->@*;
    foreach my $i (0 .. $#resultset) {
      my $p = $self->make_participant_record($resultset[$i]->@*);
      split_names($p, $res->json->{auxData}->{rowFirstNameLens}->[$i]);
      separate_division_groups($p);
      normalize_times($p);
      push(@results, $p);
    }

    $res = $self->fetch_results(++$page);
  } while ($res->json->{resultSet}->{results}->@*);

  return [@results];
}

sub make_participant_record ($self, @fields) {
  my %record = map {$self->get_record_key($_) => $fields[$_]} (0 .. $#fields);
  delete($record{$EMPTY});
  return {%record};
}

sub fetch_results ($self, $page = 1) {
  my $url = Mojo::URL->new(sprintf($results_api_url, $self->event_id));
  $url->query(resultSetId => $self->race_id, page => $page, num => $per_page, search => $EMPTY);

  return Mojo::UserAgent->new()->get($url => {Accept => 'application/json'})->result;
}

sub url ($self) {
  return undef unless (defined($results_url) && defined($self->event_id) && defined($self->race_id));

  return sprintf($results_url, $self->event_id, $self->race_id);
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
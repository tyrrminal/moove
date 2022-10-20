package Moove::Import::Event::RaceWire;
use v5.36;
use Moose;
with 'Moove::Import::Event::Base';

use Readonly;
use DateTime::Format::Strptime;
use Lingua::EN::Titlecase;
use Moove::Util::Unit::Normalization qw(normalize_times);

use DCS::Constants qw(:symbols);

use builtin      qw(true);
use experimental qw(builtin);

Readonly::Scalar my $results_url     => 'https://my.racewire.com/results/%d/%d';
Readonly::Scalar my $results_api_url => 'https://racewireapi.global.ssl.fastly.net/raceevent_results/';

has 'event_id' => (
  is       => 'ro',
  isa      => 'Str',
  required => true
);

has 'race_id' => (
  is  => 'ro',
  isa => 'Maybe[Str]'
);

has 'key_map' => (
  traits   => ['Hash'],
  is       => 'ro',
  isa      => 'HashRef[Str]',
  init_arg => undef,
  default  => sub {
    {
      'ResultId'       => '',
      'BibId'          => 'bib_no',
      'MemberId'       => '',
      'FirstName'      => 'first_name',
      'LastName'       => 'last_name',
      'City'           => 'city',
      'State'          => 'state',
      'PostCode'       => '',
      'Gender'         => 'gender',
      'Age'            => 'age',
      'AgeGroup'       => 'division',
      'ChipTimeString' => 'net_time',
      'OverallPlace'   => 'overall_place',
      'OverallCount'   => 'overall_count',
      'GenderPlace'    => 'gender_place',
      'GenderCount'    => 'gender_count',
      'AGPlace'        => 'div_place',
      'AGCount'        => 'div_count'
    };
  },
  handles => {
    get_key => 'get'
  }
);

sub _build_results ($self) {
  my $results = Mojo::URL->new($results_api_url . join('/', grep {defined} ($self->event_id, $self->race_id)));
  my $ua      = Mojo::UserAgent->new();
  my $res     = $ua->get($results => {Accept => 'application/json'})->result->json;

  my $keys = [map {$self->get_key($_)} @{$res->{"Index"}}];

  return [map {_build_participant_hash($keys, $_)} @{$res->{"Data"}}];
}

sub url ($self) {
  return undef unless (defined($results_url) && defined($self->event_id) && defined($self->race_id));

  return sprintf($results_url, $self->event_id, $self->race_id);
}

sub _build_participant_hash ($keys, $values) {
  my %p;
  @p{@$keys} = @$values;    #merge arrays
  delete($p{$EMPTY});       #remove unused components
  _fix_names(\%p);          #recapitalize names
  normalize_times(\%p);
  return {%p};
}

sub _fix_names ($p) {
  my @suffixes = qw(Jr Jr. Sr Sr. II III IV V);    #racewire puts these in last_name when they should be in first_name
  my $tc       = Lingua::EN::Titlecase->new(word_punctuation => "[.]");

  $p->{first_name} = $tc->title($p->{first_name});
  $p->{last_name}  = $tc->title($p->{last_name});

  foreach my $s (@suffixes) {
    if ($p->{last_name} =~ /\s+\Q$s\E\s*$/i) {
      $p->{first_name} .= " $s";
      $p->{last_name} =~ s/\s+\Q$s\E\s*//;
    }
  }
}

1;

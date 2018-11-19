package CardioTracker::Import::Event::RaceWire;
use Modern::Perl;
use Moose;

use DateTime::Format::Strptime;
use Lingua::EN::Titlecase;
use CardioTracker::Import::Helper::Rectification qw(normalize_times);

use DCS::Constants qw(:boolean :existence :symbols);

use Data::Dumper;

has 'event_id' => (
  is => 'ro',
  isa => 'Str',
  required => $TRUE
);

has 'race_id' => (
  is => 'ro',
  isa => 'Maybe[Str]'
);

has 'md_url' => (
  is => 'ro',
  isa => 'Str',
  init_arg => $NULL,
  default => 'https://my.racewire.com/results/'
);

has 'results_url' => (
  is => 'ro',
  isa => 'Str',
  init_arg => $NULL,
  default => 'https://racewireapi.global.ssl.fastly.net/raceevent_results/'
);

has 'key_map' => (
  traits => ['Hash'],
  is => 'ro',
  isa => 'HashRef[Str]',
  init_arg => $NULL,
  default => sub {
    {
      'ResultId' => '',
      'BibId' => 'bib_no',
      'MemberId' => '',
      'FirstName' => 'first_name',
      'LastName' => 'last_name',
      'City' => 'city',
      'State' => 'state',
      'PostCode' => '',
      'Gender' => 'gender',
      'Age' => 'age',
      'AgeGroup' => 'division',
      'ChipTimeString' => 'net_time',
      'OverallPlace' => 'overall_place',
      'OverallCount' => 'overall_count',
      'GenderPlace' => 'gender_place',
      'GenderCount' => 'gender_count',
      'AGPlace' => 'div_place',
      'AGCount' => 'div_count'
    }
  },
  handles => {
    get_key => 'get'
  }
);

sub get_metadata {
  my $self=shift;

  my $p = DateTime::Format::Strptime->new(
    pattern => '%b %d %Y',
    locale => 'en_US',
    time_zone => 'America/New_York'
  );

  my $md = Mojo::URL->new($self->md_url . join('/', grep {defined} ($self->event_id, $self->race_id)));

  my $ua = Mojo::UserAgent->new();
  my $res = $ua->get($md)->result;

  my $title = $res->dom->find('#BodyPlaceHolder_raceTitle > a')->[0]->text;
  my $date  = $res->dom->find('#BodyPlaceHolder_raceDate')->[0]->text;
  my $city  = $res->dom->find('#BodyPlaceHolder_raceCity')->[0]->text;
  my $state = $res->dom->find('#BodyPlaceHolder_raceState')->[0]->text;

  my $dt = $p->parse_datetime($date);
  my $tc = Lingua::EN::Titlecase->new($city);

  return {
    title => $title,
    location => sprintf("%s, %s", $tc, uc($state)),
    date => $dt
  };
}

sub find_and_update_event {
  my $self=shift;
  my ($model) = @_;

  my $info = $self->get_metadata();
  
  my ($event) = grep { $_->scheduled_start->year == $info->{date}->year } $model->search({name => $info->{title}})->all;
  die sprintf("Event '%s' (%d) not found\n", $info->{title}, $info->{date}->year) unless(defined($event));

  return $event;
}

sub fetch_results {
  my $self=shift;

  my $results = Mojo::URL->new($self->results_url . join('/', grep {defined} ($self->event_id, $self->race_id)));
  my $ua = Mojo::UserAgent->new();
  my $res = $ua->get($results => {Accept => 'application/json'})->result->json;

  my $keys = [map { $self->get_key($_) } @{$res->{"Index"}}];

  return map { _build_participant_hash($keys, $_) } @{$res->{"Data"}};
}

sub _build_participant_hash {
  my ($keys,$values) = @_;

  my %p;
  @p{@$keys} = @$values; #merge arrays
  delete($p{$EMPTY});    #remove unused components
  _fix_names(\%p);       #recapitalize names
  normalize_times(\%p);
  return {%p};
}

sub _fix_names {
  my $p = shift;

  my @suffixes = qw(Jr Jr. Sr Sr. II III IV V); #racewire puts these in last_name when they should be in first_name
  my $tc = Lingua::EN::Titlecase->new(word_punctuation => "[.]");

  $p->{first_name} = $tc->title($p->{first_name});
  $p->{last_name} = $tc->title($p->{last_name});

  foreach my $s (@suffixes) {
    if($p->{last_name} =~ /\s+\Q$s\E\s*$/i) {
      $p->{first_name} .= " $s";
      $p->{last_name} =~ s/\s+\Q$s\E\s*//;
    }
  }
}



1;

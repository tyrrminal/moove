package Moove::Import::Event::RunSignup::Custom;
use v5.38;
use builtin qw(true);

use Moose;
with 'Moove::Import::Event::Base';

use Mojo::DOM;
use Readonly;
use Moove::Util::Unit::Normalization qw(normalize_times);

use DCS::Constants qw(:symbols);

use experimental qw(builtin);

Readonly::Scalar my $PAGE_SIZE       => 50;
Readonly::Scalar my $RESULTS_URL     => 'https://runsignup.com/Race/Results/%s?customResultsPageId=%s';
Readonly::Scalar my $RESULTS_API_URL => 'https://runsignup.com/Race/Results/%s';

has 'key_map' => (
  traits   => ['Hash'],
  is       => 'ro',
  isa      => 'HashRef[Str]',
  init_arg => undef,
  default  => sub {
    {
      'Place'      => 'overall_place',
      'First Name' => 'first_name',
      'Last Name'  => 'last_name',
      'Chip Time'  => 'net_time',
      'Pace'       => 'pace',
      'Div place'  => 'div_place',
      'Div'        => 'division',
      'Bib'        => 'bib_no',
      'Clock Time' => 'gross_time'
    }
  },
  handles => {
    get_key => 'get'
  }
);

has '_headings' => (
  is       => 'rw',
  isa      => 'ArrayRef[Str|Undef]',
  init_arg => undef,
);

sub url ($self) {
  return undef unless (defined($RESULTS_URL) && defined($self->event_id) && defined($self->race_id));
  return sprintf($RESULTS_URL, $self->event_id, $self->race_id);
}

sub _build_results ($self) {
  my $page = 1;
  my (@results, @new_results);
  do {
    @new_results = ();
    my $res = $self->fetch_results($page++);

    my $html = $res->json->{html};
    my $dom  = Mojo::DOM->new($html);

    my $t = $dom->find('table.results')->first;

    my @headings;
    $t->find('thead>tr>th')->each(sub ($el, $num) {$headings[$num - 1] = $self->get_key($el->text) if ($self->get_key($el->text))});
    $self->_headings(\@headings);

    $t->find('tbody>tr')->each(sub ($el, $num) {push(@new_results, $self->make_participant_record($el))});

    push(@results, @new_results);
  } while (@new_results == $PAGE_SIZE);
  return \@results;
}

sub fetch_results ($self, $page = 1) {
  my $url = Mojo::URL->new(sprintf($RESULTS_API_URL, $self->event_id));
  $url->query(customResultsPageId => $self->race_id, page => $page, num => $PAGE_SIZE);
  my $params = {
    segmentId      => $self->import_params->{segment_id},
    search         => undef,
    sortColumnNum  => undef,
    sortColumnDesc => undef,
  };

  my $req = $self->ua->post($url => {Accept => 'application/json'} => form => $params);
  return $req->result;
}

sub make_participant_record ($self, $el) {
  my $p;
  my $fields = $el->find('td');
  $fields->each(
    sub ($el, $num) {
      $p->{$self->_headings->[$num - 1]} = $el->all_text
        if (defined($self->_headings->[$num - 1]));
    }
  );
  $p->{gender} = substr($p->{division}, 0, 1);
  normalize_times($p);
  return $p;
}

1;

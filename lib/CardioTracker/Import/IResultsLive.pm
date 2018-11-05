package CardioTracker::Import::IResultsLive;
use Modern::Perl;
use Moose;

use DateTime::Format::Strptime;

use DCS::Constants qw(:boolean :existence);

has 'base_url' => (
  is => 'ro',
  isa => 'Str',
  init_arg => $NULL,
  default => 'http://www.iresultslive.com/'
);

has 'key_map' => (
  traits => ['Hash'],
  is => 'ro',
  isa => 'HashRef',
  default => sub { {
    'No.'      => 'bib_no',
  } },
  handles => {
    'get_key' => 'get'
  }
);

sub get_metadata {
  my $self=shift;
  my ($eid)=@_;

  my $p = DateTime::Format::Strptime->new(
    pattern => '%a %b %d, %Y',
    locale => 'en_US',
    time_zone => 'America/New_York'
  );

  my $md = Mojo::URL->new($self->base_url);
  $md->query(op => 'summary', eid => $eid);

  my $ua = Mojo::UserAgent->new();
  my $res = $ua->get($md)->result;

  my $title_c = $res->dom->find('div.container > h1');
  my $title = $title_c->[0]->text;

  my ($date,$location) = @{$res->dom->find('em')->map('text')->to_array()};
  my $dt = $p->parse_datetime($date);

  my $races = $res->dom->find('div.row')->[1]->find('td:first-child')->map('text')->to_array();

  return {
    title => $title,
    location => $location,
    date => $dt,
    races => $races
  };
}

sub get_results {
  my $self=shift;
  my ($eid,$raceid)=@_;

  my $results = Mojo::URL->new($self->base_url);
  $results->query(op => 'overall', eid => $eid, racename => $raceid, place => 0);

  my $ua = Mojo::UserAgent->new();
  my $res = $ua->get($results)->result;

  #Column Headings
  my @col_map = #map { $self->get_key($_) // '' }
    @{$res->dom->find('table.table-condensed > thead > tr > th')->map(sub { 
      if($_->children('a')->size) { 
        my $url = Mojo::URL->new($_->children('a')->[0]->attr('href')); 
        $url->query->param('sort'); # we want the sort param from the link's href if it's a link
      } else { 
        $self->get_key($_->text); # and the cell text otherwise
      } 
    })->to_array};
  shift(@col_map); # first column participant links
  
  my @results;
  while() {
    my $n = 0;
    $res->dom->find('table.table-condensed > tbody > tr')->each(sub {
      my ($e,$num)=@_;
      my %record;
      my @values = @{$e->children('td')->map('text')->to_array};
      shift(@values); # first column participant links
      @record{@col_map} = @values;
      $n = push(@results, {%record});
    });
    last unless $n;

    $results->query(op => 'overall', eid => $eid, racename => $raceid, place => $n);
    $res = $ua->get($results)->result;
  }

  return @results;
}

1;

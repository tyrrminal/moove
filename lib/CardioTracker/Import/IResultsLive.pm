package CardioTracker::Import::IResultsLive;
use Modern::Perl;
use Moose;

use DCS::Constants;

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

sub get_races {
  my $self=shift;
  my ($res)=@_;

  return { map { $_->text => $self->base_url.$_->attr('href') } @{$res->dom->find('ul.nav-tabs:not(.red) > li > a')->to_array} };
}

sub get_results {
  my $self=shift;
  my ($eid,$raceid)=@_;

  my $results = Mojo::URL->new($self->base_url);
  $results->query(op => 'overall', eid => $eid, racename => $raceid, place => 0);

  my $ua = Mojo::UserAgent->new();
  my $res = $ua->get($results)->result;

  my $title_c = $res->dom->find('div.container > h1');
  my $title = $title_c->[0]->text;

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
  #say Data::Dumper->Dump([\@col_map]); return;
  
  my (@results, @new);
  do {
    push(@results, @new); @new = ();
    $res->dom->find('table.table-condensed > tbody > tr')->each(sub {
      my ($e,$num)=@_;
      my %record;
      my $values = $e->children('td')->map('text')->to_array;
      shift(@$values); # first column participant links
      @record{@col_map} = @$values;
      push(@new, {%record});
    });

    $results->query(op => 'overall', eid => $eid, racename => $raceid, place => $results->query->param('place')+100);
    $res = $ua->get($results)->result;
  } while(@new);

  return {title => $title, results => [@results]};
}

1;

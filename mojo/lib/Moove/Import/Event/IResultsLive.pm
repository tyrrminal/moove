package Moove::Import::Event::IResultsLive;
use Modern::Perl;
use Moose;

use boolean;
use DateTime::Format::Strptime;

use Role::Tiny::With;
with 'Moove::Role::Unit::Normalization';

use DCS::Constants qw(:existence);

has 'race_id' => (
  is     => 'rw',
  isa    => 'Str|Undef',
  writer => '_set_race_id'
);

has 'event_id' => (
  is       => 'ro',
  isa      => 'Str',
  required => true
);

has 'base_url' => (
  is       => 'ro',
  isa      => 'Str',
  init_arg => $NULL,
  default  => 'http://www.iresultslive.com/'
);

has '_url' => (
  is       => 'ro',
  isa      => 'Mojo::URL',
  init_arg => $NULL,
  lazy     => true,
  builder  => '_build_url'
);

has 'key_map' => (
  traits  => ['Hash'],
  is      => 'ro',
  isa     => 'HashRef',
  default => sub {
    {
      'No.'      => 'bib_no',
      'sex'      => 'gender',
      'gun_time' => 'gross_time'
    };
  },
  handles => {
    'get_key' => 'get'
  }
);

sub _build_url {
  my $self = shift;

  my $md = Mojo::URL->new($self->base_url);
  return $md->query(op => 'overall', eid => $self->event_id, racename => $self->race_id);
}

sub url {
  return shift->_url->to_string;
}

sub fetch_metadata {
  my $self = shift;
  my $eid  = $self->event_id;

  my $p = DateTime::Format::Strptime->new(
    pattern   => '%a %b %d, %Y',
    locale    => 'en_US',
    time_zone => 'America/New_York'
  );

  my $md = Mojo::URL->new($self->base_url);
  $md->query(op => 'summary', eid => $eid);

  my $ua  = Mojo::UserAgent->new();
  my $res = $ua->get($md)->result;

  my $title_c = $res->dom->find('div.container > h1');
  my $title   = $title_c->[0]->text;

  my ($date, $address) = @{$res->dom->find('em')->map('text')->to_array()};
  my $dt = $p->parse_datetime($date);

  my $races_c  = $res->dom->find('div.row')->[1];
  my $races    = $races_c->find('td:nth-child(1)')->map('text')->to_array();
  my $entrants = $races_c->find('td:nth-child(2)')->map('text')->to_array();
  my %races;
  @races{@$races} = @$entrants;

  return {
    title   => $title,
    address => $address,
    date    => $dt,
    races   => \%races
  };
}

sub find_and_update_event {
  my $self = shift;
  my ($model) = @_;

  my $info  = $self->fetch_metadata();
  my @races = keys(%{$info->{races}});
  if (@races == 1) {
    $self->_set_race_id($races[0]);
  } elsif (!defined($info->{races}->{$self->race_id})) {
    die "Race identifier '" . $self->race_id . "' not found\n";
  }
  my ($event) = $model->find_event($info->{date}->year, $info->{title});
  die "Event '" . $info->{title} . "' not found\n" unless (defined($event));

  $event->entrants($info->{races}->{$self->race_id});
  $event->update;
  return $event;
}

sub fetch_results {
  my $self = shift;

  my $ua  = Mojo::UserAgent->new();
  my $res = $ua->get($self->_url)->result;

  #Column Headings
  my @col_map = @{
    $res->dom->find('table.table-condensed > thead > tr > th')->map(
      sub {
        my $v;
        if ($_->children('a')->size) {
          my $url = Mojo::URL->new($_->children('a')->[0]->attr('href'));
          $v = $url->query->param('sort');    # we want the sort param from the link's href if it's a link
        } else {
          $v = $_->text;                      # and the cell text otherwise
        }
        $self->get_key($v) // $v;
      }
      )->to_array
  };
  shift(@col_map);                            # first column participant links

  my @results;
  while () {
    my $n = 0;
    $res->dom->find('table.table-condensed > tbody > tr')->each(
      sub {
        my ($e, $num) = @_;
        my %record;
        my @values = @{$e->children('td')->map('text')->to_array};
        shift(@values);                       # first column participant links
        @record{@col_map} = @values;
        normalize_times(\%record);
        $n = push(@results, {%record});
      }
    );
    last unless $n;

    my $results = Mojo::URL->new($self->base_url);
    $results->query(op => 'overall', eid => $self->event_id, racename => $self->race_id, place => $n);
    $res = $ua->get($results)->result;
  }

  return @results;
}

1;

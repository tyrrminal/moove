package Moove::Import::Event::IResultsLive;
use v5.38;
use Moose;
with 'Moove::Import::Event::Base';

use DateTime::Format::Strptime;
use Moove::Util::Unit::Normalization qw(normalize_times);
use JSON::Validator::Joi             qw(joi);

use builtin      qw(true);
use experimental qw(builtin);

has 'base_url' => (
  is       => 'ro',
  isa      => 'Str',
  init_arg => undef,
  default  => 'http://www.iresultslive.com/'
);

has '_url' => (
  is       => 'ro',
  isa      => 'Mojo::URL',
  init_arg => undef,
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

sub _build_import_param_schemas ($class) {
  return {
    event => JSON::Validator->new()->schema(
      joi->object->strict->props(
        event_id => joi->integer->required,
        )->compile
    ),
    eventactivity => JSON::Validator->new()->schema(
      joi->object->strict->props(
        race_id => joi->string,
        )->compile
    )
  };
}

sub _build_url ($self) {
  my $md = Mojo::URL->new($self->base_url);
  return $md->query(op => 'overall', eid => $self->event_id, racename => $self->race_id);
}

sub url ($self) {
  return undef unless (defined($self->event_id) && defined($self->race_id));
  return $self->_url->to_string;
}

sub _build_results ($self) {
  my $res = $self->ua->get($self->_url)->result;

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
  shift(@col_map);    # first column participant links

  my @results;
  while () {
    my $n = 0;
    $res->dom->find('table.table-condensed > tbody > tr')->each(
      sub {
        my ($e, $num) = @_;
        my %record;
        my @values = @{$e->children('td')->map('text')->to_array};
        shift(@values);    # first column participant links
        @record{@col_map} = @values;
        normalize_times(\%record);
        $n = push(@results, {%record});
      }
    );
    last unless $n;

    my $results = Mojo::URL->new($self->base_url);
    $results->query(op => 'overall', eid => $self->event_id, racename => $self->race_id, place => $n);
    $res = $self->ua->get($results)->result;
  }

  return [@results];
}

1;

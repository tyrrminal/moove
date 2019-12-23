package Moove::Import::Event::MillenniumRunning;
use Modern::Perl;
use Moose;

use DateTime::Format::Strptime;
use Lingua::EN::Titlecase;
use List::MoreUtils qw(uniq);
use Moove::Import::Helper::Rectification qw(normalize_times);
use Data::Dumper;

use Moove::Import::Helper::CityService;

use DCS::Constants qw(:boolean :existence :symbols);

has 'event_id' => (
  is       => 'ro',
  isa      => 'Str',
  required => $TRUE
);

has 'race_id' => (
  is      => 'ro',
  isa     => 'Undef',
  default => $NULL
);

has 'base_url' => (
  is       => 'ro',
  isa      => 'Str',
  init_arg => $NULL,
  default  => 'http://www.millenniumrunning.com/'
);

has '_url' => (
  is       => 'ro',
  isa      => 'Mojo::URL',
  init_arg => $NULL,
  lazy     => $TRUE,
  builder  => '_build_url'
);

has 'results_page' => (
  is       => 'ro',
  isa      => 'Mojo::Message::Response',
  init_arg => $NULL,
  lazy     => $TRUE,
  builder  => '_build_results_page'
);

has '_event_state' => (
  is       => 'rw',
  isa      => 'Str',
  init_arg => $NULL
);

has 'key_map' => (
  traits  => ['Hash'],
  is      => 'ro',
  isa     => 'HashRef',
  default => sub {
    {
      'Place'   => 'overall_place',
      'Div/Tot' => 'div_place_count',
      'Div'     => 'division',
      'Name'    => 'name',
      'Age'     => 'age',
      'Sex'     => 'gender',
      'City'    => 'city',
      'Guntime' => 'gross_time',
      'Nettime' => 'net_time',
      'Pace'    => 'pace'
    };
  },
  handles => {
    'get_key' => 'get'
  }
);

sub _build_results_page {
  my $self = shift;

  my $pre = $self->_url;
  my $ua  = Mojo::UserAgent->new();
  my $res = $ua->get($pre)->result;

  unless ($res->body) {
    return $ua->get($res->headers->address)->result;
  }
  return $pre;
}

sub _build_url {
  my $self = shift;

  return Mojo::URL->new($self->base_url . join('/', grep {defined} ($self->race_id // 'x', $self->event_id)));
}

sub url {
  return shift->_url->to_string;
}

sub fetch_metadata {
  my $self = shift;
  my $eid  = $self->event_id;

  my $p = DateTime::Format::Strptime->new(
    pattern   => '%m/%d/%Y',
    locale    => 'en_US',
    time_zone => 'America/New_York'
  );

  my $res = $self->results_page;

  my ($address, $dt);
  my $md = $res->dom->find('div.header > h3')->[0]->text;
  $md =~ s|<br\s*/?>||;
  my ($title, $loc_date) = split($/, $md);
  $title =~ s/\x{2019}/'/g;
  if ($loc_date =~ m|(\w+, \w{2}) (\d{2}/\d{2}/\d{4})|) {
    $address = $1;
    $dt      = $p->parse_datetime($2);
  }

  return {
    title   => $title,
    address => $address,
    date    => $dt
  };
}

sub find_and_update_event {
  my $self = shift;
  my ($model) = @_;

  my $info = $self->fetch_metadata();
  my ($event) = $model->find_event($info->{date}->year, $info->{title});
  die "Event '" . $info->{title} . "' not found\n" unless (defined($event));

  $self->_event_state($event->address->state);

  return $event;
}

sub fetch_results {
  my $self = shift;
  my $res  = $self->results_page;

  my $cs = Moove::Import::Helper::CityService->new();

  my @results;
  my @col_map = @{$res->dom->find('div.main table tr:first-child > th')->map(sub {$self->get_key($_->text)})->to_array};
  $res->dom->find('div.main table tr:not(:first-child)')->each(
    sub {
      my %record;
      my @values = @{$_->children('td')->map('text')->to_array};
      @record{@col_map} = @values;
      _fix_names(\%record);
      normalize_times(\%record);
      _fix_div_place(\%record);
      _fix_address(\%record, $cs, $self->_event_state);
      push(@results, {%record});
    }
  );

  return @results;
}

sub _fix_div_place {
  my $v               = shift;
  my $div_place_count = delete($v->{div_place_count});
  my ($p, $c) = split(m|/|, $div_place_count);
  $v->{div_place} = $p;
  $v->{div_count} = $p;
}

sub _fix_names {
  my $v     = shift;
  my $tc    = Lingua::EN::Titlecase->new();
  my $name  = delete($v->{name});
  my @parts = split(/\s+/, $name);
  $v->{last_name} = $tc->title(pop(@parts));
  $v->{first_name} = $tc->title(join($SPACE, @parts));
}

sub _fix_address {
  my ($v, $cs, $state) = @_;
  my $tc = Lingua::EN::Titlecase->new();

  if ($v->{city} =~ /(\s+)([A-Z]{2})$/) {
    $v->{state} = $2;
    $v->{city} =~ s/$1$2$//;
  }
  $v->{city} = $tc->title($v->{city});

  unless (defined($v->{state})) {
    my @states = uniq(map {$_->{state_abbrv}} $cs->combos_with_city($v->{city}));
    if (@states == 0) {
      #
    } elsif (@states == 1) {
      $v->{state} = $states[0];
    } elsif (
      grep {
        $_ eq $state
      } @states
      )
    {
      $v->{state} = $state;
    } else {
      #
    }
  }

}

1;

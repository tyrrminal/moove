package Moove::Import::Event::MillenniumRunning;
use v5.36;
use Moose;
with 'Moove::Import::Event::Base';

use DateTime::Format::Strptime;
use Lingua::EN::Titlecase;
use List::MoreUtils qw(uniq);

use Moove::Import::Helper::CityService;
use Moove::Util::Unit::Normalization qw(normalize_times);

use DCS::Constants qw(:symbols);

use builtin      qw(true);
use experimental qw(builtin);

has 'event_id' => (
  is       => 'ro',
  isa      => 'Str',
  required => true
);

has 'race_id' => (
  is      => 'ro',
  isa     => 'Undef',
  default => undef
);

has 'base_url' => (
  is       => 'ro',
  isa      => 'Str',
  init_arg => undef,
  default  => 'http://www.millenniumrunning.com/'
);

has '_url' => (
  is       => 'ro',
  isa      => 'Mojo::URL',
  init_arg => undef,
  lazy     => true,
  builder  => '_build_url'
);

has 'results_page' => (
  is       => 'ro',
  isa      => 'Mojo::Message::Response',
  init_arg => undef,
  lazy     => true,
  builder  => '_build_results_page'
);

has '_event_state' => (
  is       => 'rw',
  isa      => 'Str',
  init_arg => undef
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

sub _build_results_page ($self) {
  my $pre = $self->_url;
  my $ua  = Mojo::UserAgent->new();
  my $res = $ua->get($pre)->result;

  unless ($res->body) {
    return $ua->get($res->headers->location)->result;
  }
  return $pre;
}

sub _build_url ($self) {
  return Mojo::URL->new($self->base_url . join('/', grep {defined} ($self->race_id // 'x', $self->event_id)));
}

sub url ($self) {
  return $self->_url->to_string;
}

sub _build_results ($self) {
  my $res = $self->results_page;

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

  return [@results];
}

sub _fix_div_place ($v) {
  my $div_place_count = delete($v->{div_place_count});
  my ($p, $c) = split(m|/|, $div_place_count);
  $v->{div_place} = $p;
  $v->{div_count} = $p;
}

sub _fix_names ($v) {
  my $tc    = Lingua::EN::Titlecase->new();
  my $name  = delete($v->{name});
  my @parts = split(/\s+/, $name);
  $v->{last_name}  = $tc->title(pop(@parts));
  $v->{first_name} = $tc->title(join($SPACE, @parts));
}

sub _fix_address ($v, $cs, $state) {
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
    } elsif (defined($state) && grep {$_ eq $state} @states) {
      $v->{state} = $state;
    } else {
      #
    }
  }

}

1;

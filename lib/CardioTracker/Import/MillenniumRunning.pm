package CardioTracker::Import::MillenniumRunning;
use Modern::Perl;
use Moose;

use DateTime::Format::Strptime;
use Lingua::EN::Titlecase;
use List::MoreUtils qw(uniq);
use Data::Dumper;

use CardioTracker::Import::Helper::CityService;

use DCS::Constants qw(:boolean :existence :symbols);

has 'event_id' => (
  is => 'ro',
  isa => 'Str',
  required => $TRUE
);

has 'race_id' => (
  is => 'ro',
  isa => 'Undef',
  default => $NULL
);

has 'base_url' => (
  is => 'ro',
  isa => 'Str',
  init_arg => $NULL,
  default => 'http://www.millenniumrunning.com/'
);

has 'results_page' => (
  is => 'ro',
  isa => 'Mojo::Message::Response',
  init_arg => $NULL,
  lazy => $TRUE,
  builder => '_build_results_page'
);

has '_event_state' => (
  is => 'rw',
  isa => 'Str',
  init_arg => $NULL
);

has 'key_map' => (
  traits => ['Hash'],
  is => 'ro',
  isa => 'HashRef',
  default => sub { {
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
  } },
  handles => {
    'get_key' => 'get'
  }
);

sub _build_results_page {
  my $self=shift;

  my $pre = Mojo::URL->new($self->base_url . join('/', grep {defined} ($self->race_id // 'x', $self->event_id)));

  my $ua = Mojo::UserAgent->new();
  my $res = $ua->get($pre)->result;

  unless($res->body) {
    return $ua->get($res->headers->location)->result;
  }
  return $pre;
}

sub fetch_metadata {
  my $self=shift;
  my $eid = $self->event_id;

  my $p = DateTime::Format::Strptime->new(
    pattern => '%m/%d/%Y',
    locale => 'en_US',
    time_zone => 'America/New_York'
  );

  my $res = $self->results_page;

  my ($location, $dt);
  my $md = $res->dom->find('div.header > h3')->[0]->text;
  $md =~ s|<br\s*/?>||;
  my ($title, $loc_date) = split($/, $md);
  $title =~ s/\x{2019}/'/g;
  if($loc_date =~ m|(\w+, \w{2}) (\d{2}/\d{2}/\d{4})|) {
    $location = $1;
    $dt = $p->parse_datetime($2);
  }

  return {
    title => $title,
    location => $location,
    date => $dt
  };
}

sub find_and_update_event {
  my $self=shift;
  my ($model)=@_;

  my $info = $self->fetch_metadata();
  my ($event) = grep { $_->activity->start_time->year == $info->{date}->year } $model->search({name => $info->{title}})->all;
  die "Event '".$info->{title}."' not found\n" unless(defined($event));

  $self->_event_state($event->location->state);

  return $event;
}

sub fetch_results {
  my $self=shift;
  my $res = $self->results_page;

  my $cs = CardioTracker::Import::Helper::CityService->new();

  my @results;
  my @col_map = @{$res->dom->find('div.main table tr:first-child > th')->map(sub { $self->get_key($_->text) })->to_array};
  $res->dom->find('div.main table tr:not(:first-child)')->each(sub {
    my %record;
    my @values = @{$_->children('td')->map('text')->to_array};
    @record{@col_map} = @values;
    _fix_names(\%record);
    _fix_times(\%record);
    _fix_div_place(\%record);
    _fix_location(\%record, $cs, $self->_event_state);
    push(@results,{%record});
  });

  return @results;
}

sub _fix_div_place {
  my $v=shift;
  my $div_place_count = delete($v->{div_place_count});
  my ($p,$c) = split(m|/|, $div_place_count);
  $v->{div_place} = $p;
  $v->{div_count} = $p;
}

sub _fix_names {
  my $v=shift;
  my $tc = Lingua::EN::Titlecase->new();
  my $name = delete($v->{name});
  my @parts = split(/\s+/,$name);
  $v->{last_name} = $tc->title(pop(@parts));
  $v->{first_name} = $tc->title(join($SPACE,@parts));
}

sub _fix_location {
  my ($v, $cs, $state) = @_;
  my $tc = Lingua::EN::Titlecase->new();

  if($v->{city} =~ /(\s+)([A-Z]{2})$/) {
    $v->{state} = $2;
    $v->{city} =~ s/$1$2$//;
  }
  $v->{city} = $tc->title($v->{city});

  unless(defined($v->{state})) {
    my @states = uniq(map { $_->{state_abbrv} } $cs->combos_with_city($v->{city}));
    if(@states == 0) {
      #
    } elsif(@states == 1) {
      $v->{state} = $states[0];
    } elsif(grep { $_ eq $state } @states) {
      $v->{state} = $state;
    } else {
      #
    }
  }
  
}

sub _fix_times {
  my $p = shift;

  foreach (qw(net_time gross_time pace)) {
    if(defined($p->{$_})) {
      unless($p->{$_} =~ /:\d{2}:/) { # force times to be h:mm:ss if they're just mm:ss
        $p->{$_} = "0:".$p->{$_};
      }
    }
  }
}

1;
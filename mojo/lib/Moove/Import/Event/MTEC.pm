package Moove::Import::Event::MTEC;
use Moose;
use Modern::Perl;

use boolean;
use Readonly;
use Scalar::Util qw(looks_like_number);
use Moove::Import::Helper::Rectification qw(normalize_times);
use Data::Dumper;

use DCS::Constants qw(:existence :symbols);

Readonly::Scalar my $metadata_url => 'https://www.mtecresults.com/race/show/%s/';
Readonly::Scalar my $results_url  => 'http://farm.mtecresults.com/race/show/%s';

has 'event_id' => (
  is       => 'ro',
  isa      => 'Str',
  required => true
);

has 'race_id' => (
  is      => 'ro',
  isa     => 'Undef',
  default => $NULL
);

has 'key_map' => (
  traits   => ['Hash'],
  is       => 'ro',
  isa      => 'HashRef[Str]',
  init_arg => $NULL,
  default  => sub {
    {
      'Bib'     => 'bib_no',
      'Name'    => 'name',
      'Sex'     => 'gender',
      'Age'     => 'age',
      'City'    => 'city',
      'State'   => 'state',
      'Overall' => 'overall_place_count',
      'SexPl'   => 'gender_place_count',
      'DivPl'   => 'div_place_count',
      'Time'    => 'net_time'
    };
  },
  handles => {
    get_key => 'get'
  }
);

sub url {
  my $self = shift;

  return sprintf($metadata_url, $self->event_id);
}

sub fetch_metadata {
  my $self = shift;

  my $p = DateTime::Format::Strptime->new(
    pattern   => '%m/%d/%Y',
    locale    => 'en_US',
    time_zone => 'America/New_York'
  );

  my $ua  = Mojo::UserAgent->new();
  my $res = $ua->get($self->url)->result;

  my $title = _trim($res->dom->find('.breadcrumb li > a')->[0]->text);

  my $info = _trim($res->dom->find('.raceinfobox div')->[1]->text);
  my ($address, $date) = split(/\s*\n\s*/, $info);
  my $dt = $p->parse_datetime($date);
  return {
    title   => $title,
    address => $address,
    date    => $dt
  };
}

sub find_and_update_event {
  my $self = shift;
  my ($model) = @_;

  my $info = $self->fetch_metadata;

  my ($event) = $model->find_event($info->{date}->year, $info->{title});
  die sprintf("Event '%s' (%d) not found\n", $info->{title}, $info->{date}->year) unless (defined($event));

  return $event;
}

sub fetch_results {
  my $self = shift;

  my $url = Mojo::URL->new(sprintf($results_url, $self->event_id));
  $url->query(overall => 'yes', perPage => 500, offset => 0);

  my $ua  = Mojo::UserAgent->new();
  my $res = $ua->get($url)->result;

  my @results;
  my @col_map = map {$self->get_key($_->text)} @{$res->dom->find('.runnersearch th')->to_array};
  while () {
    my $n = 0;
    $res->dom->find('.runnersearch tbody > tr')->each(
      sub {
        my %record;
        my @values = map {_trim($_->text)} @{$_->find('td > a')->to_array()};
        @record{@col_map} = @values;
        _fix_name(\%record);
        normalize_times(\%record);
        _fix_address(\%record);
        _fix_place(\%record);
        _fix_age(\%record);
        _fix_division(\%record);
        $n = push(@results, {%record});
      }
    );
    last unless $n;

    $url->query(overall => 'yes', perPage => 500, offset => $n);
    $res = $ua->get($url)->result;
  }

  return @results;
}

sub _trim {
  my ($str) = @_;
  $str =~ s/^\s*//;
  $str =~ s/\s*$//;
  return $str;
}

sub _fix_name {
  my ($v)      = @_;
  my @prefixes = qw(del St St. Van De Von O);
  my @suffixes = qw(Jr Jr. Sr Sr. II II. III IV V);
  my $s;
  foreach (@suffixes) {
    if ($v->{name} =~ /\s+\Q$_\E\s*$/i) {
      $v->{name} =~ s/,?\s+\Q$_\E\s*$//i;
      $s = $_;
      last;
    }
  }
  my @parts = split(/\s+/, delete($v->{name}));
  $v->{last_name} = pop(@parts);
  foreach (@prefixes) {
    if (@parts > 1 && $parts[-1] eq $_) {
      $v->{last_name} = join($SPACE, pop(@parts), $v->{last_name});
      last;
    }
  }
  $v->{first_name} = join($SPACE, @parts) || $NULL;
  $v->{first_name} .= $SPACE . $s if (defined($v->{first_name}) && defined($s));
}

sub _fix_address {
  my ($v) = @_;
  $v->{country} = delete($v->{city}) unless (defined($v->{state}));
}

sub _fix_place {
  my ($v) = @_;
  ($v->{overall_place}, $v->{overall_count}) = split(m| / |, delete($v->{overall_place_count}));
  ($v->{gender_place},  $v->{gender_count})  = split(m| / |, delete($v->{gender_place_count}));
  ($v->{div_place},     $v->{div_count})     = split(m| / |, delete($v->{div_place_count}));
}

sub _fix_age {
  my ($v) = @_;
  $v->{age} = $NULL unless (looks_like_number($v->{age}));
}

sub _fix_division {
  my ($v) = @_;

  my @div_age_start = (0, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, '+');
  if (defined($v->{age}) && $v->{age} && defined($v->{gender}) && $v->{gender}) {
    my ($s, $i);
    foreach (@div_age_start) {
      $i = $_;
      last unless (looks_like_number($i));
      last if ($v->{age} < $i--);
      $s = sprintf("%02d", $i + 1);
    }
    $v->{division} = sprintf('%s%s%s', $v->{gender}, $s, $i);
  }
}

1;

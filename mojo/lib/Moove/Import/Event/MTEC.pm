package Moove::Import::Event::MTEC;
use v5.38;
use Moose;
with 'Moove::Import::Event::Base';

use Readonly;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;
use JSON::Validator::Joi qw(joi);
use Moove::Util::Unit::Normalization qw(normalize_times);

use DCS::Constants qw(:symbols);

use builtin      qw(true);
use experimental qw(builtin);

use Moove::Import::Event::Constants qw(:event);

Readonly::Scalar my $METADATA_URL => 'https://www.mtecresults.com/race/show/%s/';
Readonly::Scalar my $RESULTS_URL  => 'https://www.mtecresults.com/race/show/%s';

has 'key_map' => (
  traits   => ['Hash'],
  is       => 'ro',
  isa      => 'HashRef[Str]',
  init_arg => undef,
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

sub _build_import_param_schemas($class) {
  return {
    event => JSON::Validator->new()->schema(
      joi->object->strict->props(
        event_id => joi->integer->required,
      )
    ),
    eventactivity => JSON::Validator->new()->schema(
      joi->object->strict->props()
    )
  }
}

sub url ($self) {
  return undef unless (defined($self->event_id));
  return sprintf($METADATA_URL, $self->event_id);
}

sub _build_results ($self) {
  my $url = Mojo::URL->new(sprintf($RESULTS_URL, $self->event_id));
  $url->query(overall => 'yes', perPage => 500, offset => 0);

  my $ua  = Mojo::UserAgent->new();
  my $res = $ua->get($url)->result;

  my @results;
  my @col_map = map {$self->get_key($_->text)} @{$res->dom->find('.runnersearch-header-cell')->to_array};
  while () {
    my $n = 0;
    $res->dom->find('.runnersearch-row')->each(
      sub {
        my %record;
        my @values = map {_trim($_->text)} @{$_->find('.runnersearch-cell > a')->to_array()};
        @record{@col_map} = @values;
        $self->split_names(\%record);
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

  return [@results];
}

sub _trim ($str) {
  $str =~ s/^\s*//;
  $str =~ s/\s*$//;
  return $str;
}

sub _fix_address ($v) {
  $v->{country} = delete($v->{city}) unless (defined($v->{state}));
}

sub _fix_place ($v) {
  ($v->{overall_place}, $v->{overall_count}) = split(m| / |, delete($v->{overall_place_count}));
  ($v->{gender_place},  $v->{gender_count})  = split(m| / |, delete($v->{gender_place_count}));
  ($v->{div_place},     $v->{div_count})     = split(m| / |, delete($v->{div_place_count}));
}

sub _fix_age ($v) {
  $v->{age} = undef unless (looks_like_number($v->{age}));
}

sub _fix_division ($v) {
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

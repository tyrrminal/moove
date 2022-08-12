package Moove::Import::Activity::RunKeeper;
use v5.36;

use Moose;

use Role::Tiny::With;
with 'Moove::Role::Unit::Normalization';

use File::Spec;
use DateTime::Format::Strptime;
use IO::Uncompress::Unzip qw(unzip);
use Text::CSV_XS;
use Geo::Gpx;

use DCS::Constants qw(:symbols);

use builtin      qw(true false);
use experimental qw(builtin);

# Activity Id,Date,Type,Route Name,Distance (mi),Duration,Average Pace,Average Speed (mph),Calories Burned,
# Climb (ft),Average Heart Rate (bpm),Friend's Tagged,Notes,GPX File

has 'key_map' => (
  traits   => ['Hash'],
  is       => 'ro',
  isa      => 'HashRef[Str]',
  init_arg => undef,
  default  => sub {
    {
      'Activity Id'              => 'activity_id',
      'Date'                     => 'date',
      'Type'                     => 'type',
      'Route Name'               => 'route',
      'Distance (mi)'            => 'distance',
      'Duration'                 => 'net_time',
      'Average Pace'             => 'pace',
      'Average Speed (mph)'      => 'speed',
      'Calories Burned'          => 'cal',
      'Climb (ft)'               => 'climb',
      'Average Heart Rate (bpm)' => 'heart_rate',
      'Friend\'s Tagged'         => 'tagged',
      'Notes'                    => 'notes',
      'GPX File'                 => 'gpx',
    };
  },
  handles => {
    get_key => 'get'
  }
);

has 'type_map' => (
  traits   => ['Hash'],
  is       => 'ro',
  isa      => 'HashRef[Str]',
  init_arg => undef,
  default  => sub {
    {
      'Running'  => 'Run',
      'Cycling'  => 'Ride',
      'Swimming' => 'Swim',
      'Rowing'   => 'Kayak',
      'Walking'  => 'Walk',
      'Other'    => 'Walk'
    };
  },
  handles => {
    get_type => 'get'
  }
);

sub get_activities ($self, $asset) {
  my $zip = $asset->slurp();
  unzip(\$zip => \my $activities, Name => 'cardioActivities.csv');

  my $csv = Text::CSV_XS->new({binary => true, auto_diag => true});
  my $p   = DateTime::Format::Strptime->new(
    pattern   => '%F %T',
    locale    => 'en_US',
    time_zone => 'America/New_York'
  );

  my @activities;
  open(my $F, '<:encoding(utf8)', \$activities) or die($!);
  my @col_map = map {$self->get_key($_)} @{$csv->getline($F)};
  while (my $row = $csv->getline($F)) {
    my %v = (importer => 'RunKeeper');
    @v{@col_map} = @$row;
    $v{date}     = $p->parse_datetime($v{date}) if (defined($v{date}));
    $v{type}     = $self->get_type($v{type});
    $self->normalize_times(\%v);
    $self->_extract_temp(\%v);
    if ($v{gpx}) {
      $self->_calculate_gross_time($zip, \%v);
      $self->_add_points($zip, \%v);
    }
    push(@activities, {%v});
  }
  return @activities;
}

sub _calculate_gross_time ($self, $zip, $v) {
  unzip(\$zip => \my $data, Name => $v->{gpx});
  my $gpx = Geo::Gpx->new(xml => $data, use_datetime => true);

  my @segments = map {@{$_->{segments}}} @{$gpx->tracks};
  my $f_p      = $segments[0]->{points}->[0];
  my $l_p      = $segments[-1]->{points}->[-1];

  $v->{gross_time} = $l_p->{time}->subtract_datetime($f_p->{time});
}

sub _add_points ($self, $zip, $v) {
  unzip(\$zip => \my $data, Name => $v->{gpx});
  my $gpx = Geo::Gpx->new(xml => $data, use_datetime => true);

  $v->{activity_points} = [map {@{$_->{points}}} map {@{$_->{segments}}} @{$gpx->tracks}];
}

sub _extract_temp {
  my $self = shift;
  my ($v) = @_;

  if (my $note = $v->{notes}) {
    if ($note =~ /(\d+(?:\.\d+)?) degrees/) {
      $v->{temperature} = $1;
    }
  }
}

1;

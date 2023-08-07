package Moove::Import::Activity::RunKeeper;
use v5.36;
use Moose;

use File::Spec;
use DateTime::Format::Strptime;
use IO::Uncompress::Unzip qw(unzip);
use Text::CSV_XS;
use Geo::Gpx;
use Moove::Util::Unit::Normalization qw(normalize_time);

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

has 'file' => (
  is       => 'ro',
  isa      => 'Str',
  required => true,
);

has 'activity_data' => (
  is       => 'ro',
  isa      => 'ArrayRef[HashRef]',
  init_arg => undef,
  lazy     => true,
  builder  => '_build_activity_data'
);

sub _build_activity_data ($self) {
  my ($activities, @activities);
  unzip($self->file => \$activities, Name => 'cardioActivities.csv');

  my $csv = Text::CSV_XS->new({binary => true, auto_diag => true});
  my $p   = DateTime::Format::Strptime->new(
    pattern   => '%F %T',
    locale    => 'en_US',
    time_zone => 'America/New_York'
  );

  open(my $F, '<:encoding(utf8)', \$activities) or die($!);
  my @col_map = map {$self->get_key($_)} @{$csv->getline($F)};
  while (my $row = $csv->getline($F)) {
    my %v = (importer => 'RunKeeper');
    @v{@col_map} = @$row;
    $v{date}     = $p->parse_datetime($v{date}) if (defined($v{date}));
    $v{type}     = $self->get_type($v{type});
    push(@activities, {%v});
  }
  return \@activities;
}

sub get_activities ($self) {
  return map {$_->{activity_id}} $self->activity_data->@*;
}

sub get_activity_data ($self, $activity_id) {
  my ($activity) = grep {$activity_id eq $_->{activity_id}} $self->activity_data->@*;

  if ($activity->{notes} && $activity->{notes} =~ /(\d+(?:\.\d+)?) degrees/) {$activity->{temperature} = $1;}
  foreach (qw(net_time gross_time pace)) {$activity->{$_} = normalize_time($activity->{$_})}
  if ($activity->{gpx}) {
    $activity->{gross_time}      = $self->_get_gross_time($activity);
    $activity->{activity_points} = [];
  }
  return $activity;
}

sub get_activity_location_points ($self, $activity_id) {
  my ($activity) = grep {$activity_id eq $_->{activity_id}} $self->activity_data->@*;

  unzip($self->file => \my $data, Name => $activity->{gpx});
  my $gpx = Geo::Gpx->new(xml => $data);

  return [map {@{$_->{points}}} map {@{$_->{segments}}} @{$gpx->tracks}];
}

sub _get_gross_time ($self, $activity) {
  unzip($self->file => \my $data, Name => $activity->{gpx});
  my $gpx = Geo::Gpx->new(xml => $data);

  my @segments = map {@{$_->{segments}}} @{$gpx->tracks};
  my $f_p      = $segments[0]->{points}->[0];
  my $l_p      = $segments[-1]->{points}->[-1];

  return $l_p->time_datetime->subtract_datetime($f_p->time_datetime);
}

1;

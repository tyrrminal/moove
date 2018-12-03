package CardioTracker::Import::Activity::RunKeeper;
use Modern::Perl;
use Moose;

use File::Spec;
use DateTime::Format::Strptime;
use Archive::Zip;
use Text::CSV_XS;
use Geo::Gpx;

use CardioTracker::Import::Helper::Rectification qw(normalize_times);

use DCS::Constants qw(:boolean :existence :symbols);

use Data::Printer;

has 'file' => (
  is => 'ro',
  isa => 'Str',
  required => $TRUE
);

has '_zip' => (
  is => 'ro',
  isa => 'Archive::Zip::Archive',
  init_arg => $NULL,
  lazy => $TRUE,
  builder => '_build_zip'
);

# Activity Id,Date,Type,Route Name,Distance (mi),Duration,Average Pace,Average Speed (mph),Calories Burned,
# Climb (ft),Average Heart Rate (bpm),Friend's Tagged,Notes,GPX File

has 'key_map' => (
  traits => ['Hash'],
  is => 'ro',
  isa => 'HashRef[Str]',
  init_arg => $NULL,
  default => sub {
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
    }
  },
  handles => {
    get_key => 'get'
  }
);

has 'type_map' => (
  traits => ['Hash'],
  is => 'ro',
  isa => 'HashRef[Str]',
  init_arg => $NULL,
  default => sub {
    {
      'Running'  => 'Run',
      'Cycling'  => 'Ride',
      'Swimming' => 'Swim',
      'Rowing'   => 'Kayak',
      'Walking'  => 'Walk',
      'Other'    => 'Walk'
    }
  },
  handles => {
    get_type => 'get'
  }
);

sub _build_zip {
  return Archive::Zip->new(shift->file);
}

sub fetch_activities {
  my $self=shift;
  my $activities = $self->_zip->memberNamed('cardioActivities.csv')->contents;

  my $csv = Text::CSV_XS->new ({ binary => $TRUE, auto_diag => $TRUE });
  my $p = DateTime::Format::Strptime->new(
    pattern => '%F %T',
    locale => 'en_US',
    time_zone => 'America/New_York'
  );

  my @activities;
  open(my $F, '<:encoding(utf8)', \$activities) or die($!);
  my @col_map = map { $self->get_key($_) } @{$csv->getline($F)};
  while(my $row = $csv->getline($F)) {
    my %v;
    @v{@col_map} = @$row;
    $v{date} = $p->parse_datetime($v{date}) if(defined($v{date}));
    $v{type} = $self->get_type($v{type});
    $v{type} = 'Treadmill' if($v{type} eq 'Run' && $v{gpx} eq '');
    normalize_times(\%v);
    $self->_calculate_gross_time(\%v) if($v{gpx});
    push(@activities, {%v});
  }
  return @activities;
}

sub _calculate_gross_time {
  my $self=shift;
  my ($v, $dir) = @_;
  
  my $data = $self->_zip->memberNamed($v->{gpx})->contents;
  my $gpx = Geo::Gpx->new(xml => $data, use_datetime => $TRUE);
  
  my @segments = map { @{$_->{segments}} } @{$gpx->tracks};
  my $f_p = $segments[0]->{points}->[0];
  my $l_p = $segments[-1]->{points}->[-1];

  $v->{gross_time} = $l_p->{time}->subtract_datetime($f_p->{time});
}

1;

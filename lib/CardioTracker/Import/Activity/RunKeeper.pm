package CardioTracker::Import::Activity::RunKeeper;
use Modern::Perl;
use Moose;

use DateTime::Format::Strptime;
use Text::CSV_XS;

use CardioTracker::Import::Helper::Rectification qw(normalize_times);

use DCS::Constants qw(:boolean :existence :symbols);

use Data::Dumper;

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
      'Walking'  => 'Walk'
    }
  },
  handles => {
    get_type => 'get'
  }
);

sub parse {
  my $self=shift;
  my ($f) = @_;

  my $csv = Text::CSV_XS->new ({ binary => $TRUE, auto_diag => $TRUE });
  my $p = DateTime::Format::Strptime->new(
    pattern => '%F %T',
    locale => 'en_US',
    time_zone => 'America/New_York'
  );

  my @activities;
  open(my $F, '<:encoding(utf8)', $f) or die($!);
  my @col_map = map { $self->get_key($_) } @{$csv->getline($F)};
  while(my $row = $csv->getline($F)) {
    my %v;
    @v{@col_map} = @$row;
    $v{date} = $p->parse_datetime($v{date}) if(defined($v{date}));
    $v{type} = $self->get_type($v{type});
    $v{type} = 'Treadmill' if($v{type} eq 'Run' && $v{gpx} eq '');
    normalize_times(\%v);
    push(@activities, {%v});
  }
  return @activities;
}

1;

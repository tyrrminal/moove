use v5.38;
use experimental qw(class builtin);
use builtin qw(true);

class Moove::Import::Activity::RunKeeper {
  use DateTime::Format::Strptime;
  use Geo::Gpx;
  use IO::Uncompress::Unzip qw(unzip);
  use Readonly;
  use Text::CSV_XS;

  use Moove::Util::Unit::Normalization qw(normalize_time);

  field $file :param;

  field @activity_data;

  Readonly::Hash my %KEY_MAP => (
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
  );

  Readonly::Hash my %TYPE_MAP => (
    'Running'  => 'Run',
    'Cycling'  => 'Ride',
    'Swimming' => 'Swim',
    'Rowing'   => 'Kayak',
    'Walking'  => 'Walk',
    'Other'    => 'Walk',
  );

  # Initialize activity_data
  ADJUST {
    my $activities;
    unzip($file => \$activities, Name => 'cardioActivities.csv');

    my $csv = Text::CSV_XS->new({binary => true, auto_diag => true});
    my $p   = DateTime::Format::Strptime->new(
      pattern   => '%F %T',
      locale    => 'en_US',
      time_zone => 'America/New_York'
    );

    open(my $F, '<:encoding(utf8)', \$activities) or die($!);
    my @col_map = map {$KEY_MAP{$_}} @{$csv->getline($F)};
    # Activity Id,Date,Type,Route Name,Distance (mi),Duration,Average Pace,Average Speed (mph),Calories Burned,
    # Climb (ft),Average Heart Rate (bpm),Friend's Tagged,Notes,GPX File
    while (my $row = $csv->getline($F)) {
      my %v = (importer => 'RunKeeper');
      @v{@col_map} = @$row;
      $v{date}     = $p->parse_datetime($v{date}) if (defined($v{date}));
      $v{type}     = $TYPE_MAP{$v{type}};
      push(@activity_data, {%v});
    }
  }

  method get_activities() {
    return map {$_->{activity_id}} @activity_data
  }

  method get_activity_data($activity_id) {
    my ($activity) = grep {$activity_id eq $_->{activity_id}} @activity_data;

    if($activity->{notes} && $activity->{notes}=~ /(\d+(?:\.\d+)?) degrees/) {$activity->{temperature} = $1;}
    foreach (qw(net_time gross_time pace)) {$activity->{$_} = normalize_time($activity->{$_})}
    if ($activity->{gpx}) {
      $activity->{gross_time}      = $self->calculate_gross_time($activity);
      $activity->{activity_points} = [];
    }
    return $activity;
  }

  method get_activity_location_points ($activity_id) {
    my ($activity) = grep {$activity_id eq $_->{activity_id}} @activity_data;

    unzip($file => \my $data, Name => $activity->{gpx});
    my $gpx = Geo::Gpx->new(xml => $data);

    return [map {@{$_->{points}}} map {@{$_->{segments}}} @{$gpx->tracks}];
  }

  method calculate_gross_time ($activity) {
    unzip($file => \my $data, Name => $activity->{gpx});
    my $gpx = Geo::Gpx->new(xml => $data);

    my @segments = map {@{$_->{segments}}} @{$gpx->tracks};
    my $f_p      = $segments[0]->{points}->[0];
    my $l_p      = $segments[-1]->{points}->[-1];

    return $l_p->time_datetime->subtract_datetime($f_p->time_datetime);
  }

}

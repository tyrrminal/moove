package CardioTracker::Command::import_results;
use Mojo::Base 'Mojolicious::Command';

use Modern::Perl;
use Mojo::Util 'getopt';

use CardioTracker::Import::RaceWire;
use CardioTracker::Import::IResultsLive;
use CardioTracker::Import::MillenniumRunning;
use CardioTracker::Import::MTEC;

use DCS::Constants qw(:existence);
use Data::Dumper;

has 'description' => 'Import the results from a race or ride';
has 'usage' => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run {
  my ($self,@args) = @_;
  my $import_class = 'CardioTracker::Import::';

  getopt(
    \@args,
    'iresultslive' => sub { $import_class .= 'IResultsLive' },
    'racewire'     => sub { $import_class .= 'RaceWire' },
    'millennium'   => sub { $import_class .= 'MillenniumRunning' },
    'mtec'         => sub { $import_class .= 'MTEC' },
    'id=s'         => \my $id,
    'race=s'       => \my $race
  );

  say "id is required" and exit 1 unless(defined($id));
  say "results site is required" and exit 1 unless(defined($import_class));

  my $importer = $import_class->new(event_id => $id, race_id => $race);

  my $event = $importer->find_and_update_event($self->app->model('Event'));
  say "Importing ".sprintf('%s (%d)', $event->name, $event->activity->start_time->year);
  
  foreach my $p ($importer->fetch_results()) {
    #lookup
    my $overall_place = $self->app->model('EventResultType')->find({description => 'Overall'});
    my $gender_place = $self->app->model('EventResultType')->find({description => 'Gender'});
    my $div_place = $self->app->model('EventResultType')->find({description => 'Division'});

    #lookup (create as needed)
    my $division = $p->{division} ? $self->app->model('Division')->find_or_create({name => $p->{division}}) : $NULL;
    my $location = $self->app->model('Location')->find_location(city => $p->{city}, state => $p->{state}, country => $p->{country});
    my $gender = $self->app->model('Gender')->find({description => $p->{gender}});

    #create
    my $person;
    if(!defined($p->{first_name}) && !defined($p->{last_name}) && !defined($gender) && !defined($p->{age})) {
      $person  = $self->app->model('Person')->find_or_create({first_name => 'Unknown', last_name => 'Person'});
    }  else {
      $person = $self->app->model('Person')->create({first_name => $p->{first_name}, last_name => $p->{last_name}});
    }
    my $result = $self->app->model('Result')->create({gross_time => $p->{gross_time}, pace => $p->{pace}, net_time => $p->{net_time}, activity => $event->activity});
    $self->app->model('EventResult')->create({result => $result, place => $p->{overall_place}, event_result_type => $overall_place});
    $self->app->model('EventResult')->create({result => $result, place => $p->{gender_place}, event_result_type => $gender_place}) if(defined($gender) && defined($p->{gender_place}));
    $self->app->model('EventResult')->create({result => $result, place => $p->{div_place}, event_result_type => $div_place}) if($p->{age} && defined($division) && defined($p->{div_place}));
    my $participant = $self->app->model('Participant')->create({
      result      => $result,
      bib_no      => $p->{bib_no},
      division_id => defined($division) ? $division->id : undef,
      age         => $p->{age},
      person      => $person,
      gender_id      => defined($gender) ? $gender->id : undef,
      location    => $location
    });
  }
}

1;

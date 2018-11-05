package CardioTracker::Command::import_results;
use Mojo::Base 'Mojolicious::Command';

use Modern::Perl;
use Mojo::Util 'getopt';

use CardioTracker::Import::RaceWire;
use CardioTracker::Import::IResultsLive;

use DCS::Constants;
use Data::Dumper;

has 'description' => 'Import the results from a race or ride';
has 'usage' => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run {
  my ($self,@args) = @_;
  my $importer;

  getopt(
    \@args,
    'iresultslive' => sub { $importer = CardioTracker::Import::IResultsLive->new() },
    'racewire'     => sub { $importer = CardioTracker::Import::RaceWire->new() },
    'id=s'         => \my $id,
    'race=s'       => \my $race
  );

  say "id is required" and exit 1 unless(defined($id));
  say "results site is required" and exit 1 unless(defined($importer));

  my $info = $importer->get_metadata($id);
  die "Race identifier '$race' not found\n" unless(grep {$race eq $_} @{$info->{races}});
  my @results = $importer->get_results($id,$race);
  my $event = $self->app->model('Event')->search({name => $info->{title}})->first;
  die "Event '".$info->{title}."' not found\n" unless(defined($event));
  
  foreach my $p (@results) {
    #lookup
    my $overall_place = $self->app->model('EventResultType')->find({description => 'Overall'});
    my $div_place = $self->app->model('EventResultType')->find({description => 'Division'});

    #lookup (create as needed)
    my $division = $self->app->model('Division')->find_or_create({name => $p->{division}});
    my $location = $self->app->model('Location')->find_city_state($p->{city}, $p->{state});
    my $sex = $self->app->model('Sex')->find({description => $p->{sex}});

    #create
    my $person = $self->app->model('Person')->create({first_name => $p->{first_name}, last_name => $p->{last_name}});
    my $result = $self->app->model('Result')->create({gross_time => $p->{gun_time}, pace => $p->{pace}, net_time => $p->{net_time}, activity => $event->activity});
    $self->app->model('EventResult')->create({result => $result, place => $p->{overall_place}, event_result_type => $overall_place});
    $self->app->model('EventResult')->create({result => $result, place => $p->{div_place}, event_result_type => $div_place});
    my $participant = $self->app->model('Participant')->create({
      result    => $result,
      bib_no    => $p->{bib_no},
      division  => $division,
      age       => $p->{age},
      person    => $person,
      sex       => $sex,
      location  => $location
    });
  }
}

1;

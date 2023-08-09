package Moove::Command::import_results;
use v5.38;

use Mojo::Base 'Mojolicious::Command';

use Mojo::Util 'getopt';

use Scalar::Util qw(looks_like_number);
use DateTime;

use Moove::Import::Event::RaceWire;
use Moove::Import::Event::IResultsLive;
use Moove::Import::Event::MillenniumRunning;
use Moove::Import::Event::MTEC;
use Moove::Import::Event::RaceRoster;

use Moove::Import::Helper::TextBalancedFix;

has 'description' => 'Import the results from a race or ride';
has 'usage'       => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run ($self, @args) {
  getopt(\@args, 'id=s' => \my $id,);
  my $rs;
  my $search = {scheduled_start => {'<' => DateTime::Format::Mysql->format_datetime(DateTime->now)}};
  if (defined($id)) {
    $search->{id} = $id;
    my $rs = $self->app->model('EventActivity')->search($search);
    die("EventActivity ID not found") unless ($rs->count);
  } else {
    $search->{entrants} = undef;
    $rs = $self->app->model('EventActivity')->search($search, {'order_by' => 'scheduled_start'});
  }

  foreach ($rs->all) {
    $self->import($_);
  }
}

sub import ($self, $event_activity) {
  my $id           = $event_activity->event->external_identifier;
  my $import_class = $event_activity->event->external_data_source->import_class;
  my $sub_id       = $event_activity->external_identifier;
  die "id is required"           unless (defined($id));
  die "results site is required" unless ($import_class->can('new'));

  say DateTime->now()->strftime('%F %T') . " Importing " . $event_activity->description;
  my $importer = $import_class->new(event_id => $id, race_id => $race);
  $event_activity->update({entrants => $importer->total_results});

  foreach my $p ($importer->fetch_results()) {
    $event_activity->add_participant($p);
  }

  $event_activity->add_missing_gender_groups;
  $event_activity->update_missing_group_counts;
  $event_activity->update_missing_result_paces;
}

1;

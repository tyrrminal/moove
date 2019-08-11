package CardioTracker::Command::import_activities;
use Mojo::Base 'Mojolicious::Command', -signatures;

use Mojo::Util 'getopt';

use DateTime;
use DateTime::Span;
use DateTime::Format::Duration;

use CardioTracker::Import::Activity::RunKeeper;

use CardioTracker::Import::Helper::TextBalancedFix;

use DCS::Constants qw(:boolean :existence);
use Data::Dumper;

has 'description' => 'Import Cardio Activities from File';
has 'usage'       => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

my %status_wording = (
  add    => 'Importing',
  update => 'Updating',
  skip   => 'Skipping'
);

sub run ($self, @args) {
  local $| = 1;

  my $import_class = "CardioTracker::Import::Activity::";
  my $mode;

  my $user_id = 1;
  getopt(
    \@args,
    'runkeeper' => sub {$import_class .= 'RunKeeper'},
    'file=s'    => \my $file,
    'user=s'    => \$user_id,
  );

  say "You must specify an import file"   and exit 1 unless (defined($file));
  say "File '$file' does not exist"       and exit 1 unless (-r $file);
  say "You must identify the data source" and exit 1 unless ($import_class->can('new'));

  my $user = $self->app->model('User')->find_user($user_id);
  say "You must specify a valid username or user ID" unless (defined($user));

  my $importer = $import_class->new(file => $file);
  if (defined($mode)) {

  } else {
    foreach my $activity ($importer->fetch_activities()) {
      my ($act, $status) = $self->app->model('Activity')->add_imported_activity($activity, $user);
      say sprintf('%s %s: %s %s',
        $status_wording{$status},    $act->start_time->strftime('%F'),
        $act->distance->description, $act->activity_type->description);
    }
  }
}

1;

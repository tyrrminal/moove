package Moove::Command::import_activities;
use v5.38;

use Mojo::Base 'Mojolicious::Command';

use Role::Tiny::With;
with 'Moove::Role::Import::Activity';

use DateTime;
use DateTime::Span;
use DateTime::Format::Duration;
use Module::Util qw(module_path);
use Mojo::Util 'getopt';
use Mojo::Asset::File;

has 'description' => 'Import Cardio Activities from File';
has 'usage'       => <<"USAGE";
$0 deploy [OPTIONS]
OPTIONS:
  ???
USAGE

sub run ($self, @args) {
  my ($user_id, $importer_name, $file) = (1);
  getopt(
    \@args,
    'runkeeper' => sub {$importer_name = 'RunKeeper'},
    'file=s'    => \$file,
    'user=s'    => \$user_id,
  );

  ## Validate File ##
  say "You must specify an import file" and exit 1 unless (defined($file));
  say "File '$file' does not exist"     and exit 1 unless (-r $file);

  ## Validate Data Source ##
  say "You must identify the data source" and exit 1 unless ($importer_name);
  my $ds = $self->app->model('ExternalDataSource')->search(
    {
      name         => $importer_name,
      import_class => {-like => '%::Activity::%'}
    }
  )->first;
  say "Invalid data source specified" and exit 1 unless (defined($ds));

  ## Validate User ##
  my $user = $self->app->model('User')->find_user($user_id);
  say "You must specify a valid username or user ID" unless (defined($user));

  ## Do Import ##
  require(module_path($ds->import_class));
  my $importer = $ds->import_class->new();
  my $now      = DateTime->now();
  foreach my $activity ($importer->get_activities(Mojo::Asset::File->new(path => $file))) {
    my $act    = $self->import_activity($activity, $user);
    my $status = 'Importing';
    if (defined($act->updated_at) && $act->updated_at >= $now) {
      $status = 'Updating';
    } else if ($act->last_updated_at < $now) {
      $status = 'Skipping';
    }

    say sprintf('%s %s: %s %s',
      $status,
      $act->start_time->strftime('%F'),
      $act->distance->description,
      $act->activity_type->description);
  }
}

1;

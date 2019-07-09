package CardioTracker::Command::load_schema;
use Mojo::Base 'Mojolicious::Command', -signatures;

use DBIx::Class::Schema::Loader qw(make_schema_at);
use File::Spec;
use DCS::Constants qw(:boolean);

has description => 'Import the database schema to DBIx classes';
has usage => <<"USAGE";
$0 load_schema
USAGE

sub run($self,@args) {
  my $app = $self->app;

  my $db = $app->conf->db;
  make_schema_at(
    'CardioTracker::Model', {
      debug => $TRUE,
      dump_directory => File::Spec->catfile($app->home,'lib'),
      components => [qw(Relationship::Predicate InflateColumn::DateTime InflateColumn::Time)],
      overwrite_modifications => $TRUE
    },
    [$db->dsn, $db->user, $db->pass],
  );
}

1;

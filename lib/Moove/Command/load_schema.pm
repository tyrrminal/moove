package Moove::Command::load_schema;


use Mojo::Base 'Mojolicious::Command', -signatures;

use DBIx::Class::Schema::Loader qw(make_schema_at);

has description => 'Import the database schema to DBIx classes';
has usage       => <<"USAGE";
$0 load_schema
USAGE

sub run ($self, @args) {
  make_schema_at(
    'Moove::Model', {
      debug                   => 1,
      dump_directory          => $self->app->home->child('lib')->to_string,
      components              => [qw(Relationship::Predicate InflateColumn::DateTime InflateColumn::Time Stash)],
      overwrite_modifications => 1,
      filter_generated_code   => sub ($type, $class, $text) {
        return "#<<<\n$text#>>>";
      },
    },
    [$self->app->conf->db_params],
  );
}

1;

#<<<
use utf8;
package Moove::Model::Result::ExternalDataSource;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::ExternalDataSource

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::Relationship::Predicate>

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::InflateColumn::Time>

=back

=cut

__PACKAGE__->load_components(
  "Relationship::Predicate",
  "InflateColumn::DateTime",
  "InflateColumn::Time",
);

=head1 TABLE: C<ExternalDataSource>

=cut

__PACKAGE__->table("ExternalDataSource");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 import_class

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 base_url

  data_type: 'varchar'
  is_nullable: 1
  size: 1024

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "import_class",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "base_url",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<class_name_UNIQUE>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("class_name_UNIQUE", ["name"]);

=head1 RELATIONS

=head2 activities

Type: has_many

Related object: L<Moove::Model::Result::Activity>

=cut

__PACKAGE__->has_many(
  "activities",
  "Moove::Model::Result::Activity",
  { "foreign.external_data_source_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events

Type: has_many

Related object: L<Moove::Model::Result::Event>

=cut

__PACKAGE__->has_many(
  "events",
  "Moove::Model::Result::Event",
  { "foreign.external_data_source_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>
use v5.38;

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-09 12:32:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fsvwY/XjqBQItv/GR9QgUQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

#<<<
use utf8;
package Moove::Model::Result::EventType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::EventType

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

=head1 TABLE: C<event_type>

=cut

__PACKAGE__->table("event_type");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 activity_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "activity_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 45 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<description_UNIQUE>

=over 4

=item * L</description>

=back

=cut

__PACKAGE__->add_unique_constraint("description_UNIQUE", ["description"]);

=head1 RELATIONS

=head2 activity_type

Type: belongs_to

Related object: L<Moove::Model::Result::ActivityType>

=cut

__PACKAGE__->belongs_to(
  "activity_type",
  "Moove::Model::Result::ActivityType",
  { id => "activity_type_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 events

Type: has_many

Related object: L<Moove::Model::Result::Event>

=cut

__PACKAGE__->has_many(
  "events",
  "Moove::Model::Result::Event",
  { "foreign.event_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-04-28 15:46:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KPyvq1VvDHosD49tRyvEtg


# You can replace this text with custom code or comments, and it will be preserved on regeneration

1;

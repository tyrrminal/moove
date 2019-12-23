#<<<
use utf8;
package Moove::Model::Result::ActivityType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::ActivityType

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

=head1 TABLE: C<activity_type>

=cut

__PACKAGE__->table("activity_type");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
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

=head2 activities

Type: has_many

Related object: L<Moove::Model::Result::Activity>

=cut

__PACKAGE__->has_many(
  "activities",
  "Moove::Model::Result::Activity",
  { "foreign.activity_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_types

Type: has_many

Related object: L<Moove::Model::Result::EventType>

=cut

__PACKAGE__->has_many(
  "event_types",
  "Moove::Model::Result::EventType",
  { "foreign.activity_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 goals

Type: has_many

Related object: L<Moove::Model::Result::Goal>

=cut

__PACKAGE__->has_many(
  "goals",
  "Moove::Model::Result::Goal",
  { "foreign.activity_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-02 13:17:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:husnjYW01X98i7FvJIt/xQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
sub to_hash {
  my $self = shift;

  return {
    id          => $self->id,
    description => $self->description
  };
}

1;

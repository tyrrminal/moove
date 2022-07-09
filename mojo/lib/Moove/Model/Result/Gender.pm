#<<<
use utf8;
package Moove::Model::Result::Gender;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::Gender

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

=head1 TABLE: C<Gender>

=cut

__PACKAGE__->table("Gender");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 abbreviation

  data_type: 'varchar'
  is_nullable: 0
  size: 2

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
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "abbreviation",
  { data_type => "varchar", is_nullable => 0, size => 2 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<abbreviation_UNIQUE>

=over 4

=item * L</abbreviation>

=back

=cut

__PACKAGE__->add_unique_constraint("abbreviation_UNIQUE", ["abbreviation"]);

=head2 C<name_UNIQUE>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name_UNIQUE", ["name"]);

=head1 RELATIONS

=head2 event_participants

Type: has_many

Related object: L<Moove::Model::Result::EventParticipant>

=cut

__PACKAGE__->has_many(
  "event_participants",
  "Moove::Model::Result::EventParticipant",
  { "foreign.gender_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_placement_partitions

Type: has_many

Related object: L<Moove::Model::Result::EventPlacementPartition>

=cut

__PACKAGE__->has_many(
  "event_placement_partitions",
  "Moove::Model::Result::EventPlacementPartition",
  { "foreign.gender_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>
use v5.36;

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-09 12:32:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jT/zG8OEBYLiahV8tYxZVQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub description ($self) {
  return $self->abbreviation;
}

1;

use utf8;
package CardioTracker::Model::Result::EventReference;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::EventReference

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

=head1 TABLE: C<event_reference>

=cut

__PACKAGE__->table("event_reference");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 event_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 event_reference_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 ref_num

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 sub_ref_num

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "event_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "event_reference_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "ref_num",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "sub_ref_num",
  { data_type => "varchar", is_nullable => 1, size => 45 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 event

Type: belongs_to

Related object: L<CardioTracker::Model::Result::Event>

=cut

__PACKAGE__->belongs_to(
  "event",
  "CardioTracker::Model::Result::Event",
  { id => "event_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event_reference_type

Type: belongs_to

Related object: L<CardioTracker::Model::Result::EventReferenceType>

=cut

__PACKAGE__->belongs_to(
  "event_reference_type",
  "CardioTracker::Model::Result::EventReferenceType",
  { id => "event_reference_type_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-11-19 17:38:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:61iZwkU2l3Fwg1CKEqaFzA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

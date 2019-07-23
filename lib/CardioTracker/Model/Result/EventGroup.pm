use utf8;
package CardioTracker::Model::Result::EventGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::EventGroup

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

=head1 TABLE: C<event_group>

=cut

__PACKAGE__->table("event_group");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 year

  data_type: 'integer'
  is_nullable: 0

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=head2 address_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 event_sequence_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "year",
  { data_type => "integer", is_nullable => 0 },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 512 },
  "address_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "event_sequence_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 address

Type: belongs_to

Related object: L<CardioTracker::Model::Result::Address>

=cut

__PACKAGE__->belongs_to(
  "address",
  "CardioTracker::Model::Result::Address",
  { id => "address_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event_group_series

Type: has_many

Related object: L<CardioTracker::Model::Result::EventGroupSeries>

=cut

__PACKAGE__->has_many(
  "event_group_series",
  "CardioTracker::Model::Result::EventGroupSeries",
  { "foreign.event_group_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_sequence

Type: belongs_to

Related object: L<CardioTracker::Model::Result::EventSequence>

=cut

__PACKAGE__->belongs_to(
  "event_sequence",
  "CardioTracker::Model::Result::EventSequence",
  { id => "event_sequence_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 events

Type: has_many

Related object: L<CardioTracker::Model::Result::Event>

=cut

__PACKAGE__->has_many(
  "events",
  "CardioTracker::Model::Result::Event",
  { "foreign.event_group_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_series

Type: many_to_many

Composing rels: L</event_group_series> -> event_series

=cut

__PACKAGE__->many_to_many("event_series", "event_group_series", "event_series");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-07-14 20:30:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SZCmtcmjxgsaLYH2BqnejA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

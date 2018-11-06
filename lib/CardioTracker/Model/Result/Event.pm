use utf8;
package CardioTracker::Model::Result::Event;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::Event

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::Relationship::Predicate>

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("Relationship::Predicate", "InflateColumn::DateTime");

=head1 TABLE: C<event>

=cut

__PACKAGE__->table("event");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 activity_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 entrants

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 event_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 distance_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 location_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "activity_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "entrants",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "event_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "distance_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "location_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=item * L</activity_id>

=back

=cut

__PACKAGE__->set_primary_key("id", "activity_id");

=head1 RELATIONS

=head2 activity

Type: belongs_to

Related object: L<CardioTracker::Model::Result::Activity>

=cut

__PACKAGE__->belongs_to(
  "activity",
  "CardioTracker::Model::Result::Activity",
  { id => "activity_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 distance

Type: belongs_to

Related object: L<CardioTracker::Model::Result::Distance>

=cut

__PACKAGE__->belongs_to(
  "distance",
  "CardioTracker::Model::Result::Distance",
  { id => "distance_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event_registrations

Type: has_many

Related object: L<CardioTracker::Model::Result::EventRegistration>

=cut

__PACKAGE__->has_many(
  "event_registrations",
  "CardioTracker::Model::Result::EventRegistration",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_type

Type: belongs_to

Related object: L<CardioTracker::Model::Result::EventType>

=cut

__PACKAGE__->belongs_to(
  "event_type",
  "CardioTracker::Model::Result::EventType",
  { id => "event_type_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 location

Type: belongs_to

Related object: L<CardioTracker::Model::Result::Location>

=cut

__PACKAGE__->belongs_to(
  "location",
  "CardioTracker::Model::Result::Location",
  { id => "location_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-11-06 14:46:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gr+64wYs8fuNO7rrsxL1bA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

use utf8;
package CardioTracker::Model::Result::ActivityPoint;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::ActivityPoint

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

=head1 TABLE: C<activity_point>

=cut

__PACKAGE__->table("activity_point");

=head1 ACCESSORS

=head2 activity_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 location_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 timestamp

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "activity_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "location_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "timestamp",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</activity_id>

=item * L</location_id>

=back

=cut

__PACKAGE__->set_primary_key("activity_id", "location_id");

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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-01-26 15:38:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wcATXny8MwyA8h26zWZ4Fw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

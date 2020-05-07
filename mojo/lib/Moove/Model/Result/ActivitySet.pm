#<<<
use utf8;
package Moove::Model::Result::ActivitySet;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::ActivitySet

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

=head1 TABLE: C<ActivitySet>

=cut

__PACKAGE__->table("ActivitySet");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 num

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 activity_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "num",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "activity_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 activity

Type: belongs_to

Related object: L<Moove::Model::Result::Activity>

=cut

__PACKAGE__->belongs_to(
  "activity",
  "Moove::Model::Result::Activity",
  { id => "activity_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 cardio_activity_sets

Type: has_many

Related object: L<Moove::Model::Result::CardioActivitySet>

=cut

__PACKAGE__->has_many(
  "cardio_activity_sets",
  "Moove::Model::Result::CardioActivitySet",
  { "foreign.activity_set_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hold_activity_sets

Type: has_many

Related object: L<Moove::Model::Result::HoldActivitySet>

=cut

__PACKAGE__->has_many(
  "hold_activity_sets",
  "Moove::Model::Result::HoldActivitySet",
  { "foreign.activity_set_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 lift_activity_sets

Type: has_many

Related object: L<Moove::Model::Result::LiftActivitySet>

=cut

__PACKAGE__->has_many(
  "lift_activity_sets",
  "Moove::Model::Result::LiftActivitySet",
  { "foreign.activity_set_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 outdoor_activity_sets

Type: has_many

Related object: L<Moove::Model::Result::OutdoorActivitySet>

=cut

__PACKAGE__->has_many(
  "outdoor_activity_sets",
  "Moove::Model::Result::OutdoorActivitySet",
  { "foreign.activity_set_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_goal_fulfillment_activity_sets

Type: has_many

Related object: L<Moove::Model::Result::UserGoalFulfillmentActivitySet>

=cut

__PACKAGE__->has_many(
  "user_goal_fulfillment_activity_sets",
  "Moove::Model::Result::UserGoalFulfillmentActivitySet",
  { "foreign.activity_set_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_goal_fulfillments

Type: many_to_many

Composing rels: L</user_goal_fulfillment_activity_sets> -> user_goal_fulfillment

=cut

__PACKAGE__->many_to_many(
  "user_goal_fulfillments",
  "user_goal_fulfillment_activity_sets",
  "user_goal_fulfillment",
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-05-07 12:23:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:W+v2znsrhirud37htPHnPA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

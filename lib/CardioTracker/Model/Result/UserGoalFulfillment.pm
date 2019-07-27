use utf8;
package CardioTracker::Model::Result::UserGoalFulfillment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::UserGoalFulfillment

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

=head1 TABLE: C<user_goal_fulfillment>

=cut

__PACKAGE__->table("user_goal_fulfillment");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_goal_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_goal_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
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

=head2 user_goal

Type: belongs_to

Related object: L<CardioTracker::Model::Result::UserGoal>

=cut

__PACKAGE__->belongs_to(
  "user_goal",
  "CardioTracker::Model::Result::UserGoal",
  { id => "user_goal_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user_goal_fulfillment_activities

Type: has_many

Related object: L<CardioTracker::Model::Result::UserGoalFulfillmentActivity>

=cut

__PACKAGE__->has_many(
  "user_goal_fulfillment_activities",
  "CardioTracker::Model::Result::UserGoalFulfillmentActivity",
  { "foreign.user_goal_fulfillment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 activities

Type: many_to_many

Composing rels: L</user_goal_fulfillment_activities> -> activity

=cut

__PACKAGE__->many_to_many("activities", "user_goal_fulfillment_activities", "activity");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-07-27 12:13:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OO5YMxJ5EtuO+XyhQaUzlw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

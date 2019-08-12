#<<<
use utf8;
package CardioTracker::Model::Result::UserGoalFulfillmentActivity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::UserGoalFulfillmentActivity

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

=head1 TABLE: C<user_goal_fulfillment_activity>

=cut

__PACKAGE__->table("user_goal_fulfillment_activity");

=head1 ACCESSORS

=head2 user_goal_fulfillment_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 activity_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_goal_fulfillment_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "activity_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_goal_fulfillment_id>

=item * L</activity_id>

=back

=cut

__PACKAGE__->set_primary_key("user_goal_fulfillment_id", "activity_id");

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

=head2 user_goal_fulfillment

Type: belongs_to

Related object: L<CardioTracker::Model::Result::UserGoalFulfillment>

=cut

__PACKAGE__->belongs_to(
  "user_goal_fulfillment",
  "CardioTracker::Model::Result::UserGoalFulfillment",
  { id => "user_goal_fulfillment_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-02 13:17:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qFlf1n8CcUBZt06D6MKvkQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

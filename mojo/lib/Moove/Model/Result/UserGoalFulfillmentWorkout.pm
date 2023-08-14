#<<<
use utf8;
package Moove::Model::Result::UserGoalFulfillmentWorkout;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::UserGoalFulfillmentWorkout

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

=head1 TABLE: C<UserGoalFulfillmentWorkout>

=cut

__PACKAGE__->table("UserGoalFulfillmentWorkout");

=head1 ACCESSORS

=head2 user_goal_fulfillment_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 workout_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_goal_fulfillment_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "workout_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_goal_fulfillment_id>

=item * L</workout_id>

=back

=cut

__PACKAGE__->set_primary_key("user_goal_fulfillment_id", "workout_id");

=head1 RELATIONS

=head2 user_goal_fulfillment

Type: belongs_to

Related object: L<Moove::Model::Result::UserGoalFulfillment>

=cut

__PACKAGE__->belongs_to(
  "user_goal_fulfillment",
  "Moove::Model::Result::UserGoalFulfillment",
  { id => "user_goal_fulfillment_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 workout

Type: belongs_to

Related object: L<Moove::Model::Result::Workout>

=cut

__PACKAGE__->belongs_to(
  "workout",
  "Moove::Model::Result::Workout",
  { id => "workout_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>
use v5.38;

# Created by DBIx::Class::Schema::Loader v0.07051 @ 2023-08-14 09:22:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cP1/DNLHwPbQ1JQeKVHNIg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

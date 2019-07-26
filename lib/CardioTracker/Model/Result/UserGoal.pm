use utf8;
package CardioTracker::Model::Result::UserGoal;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::UserGoal

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

=head1 TABLE: C<user_goal>

=cut

__PACKAGE__->table("user_goal");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 goal_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "goal_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<fk_user_goal_user_goal1_uniq>

=over 4

=item * L</user_id>

=item * L</goal_id>

=back

=cut

__PACKAGE__->add_unique_constraint("fk_user_goal_user_goal1_uniq", ["user_id", "goal_id"]);

=head1 RELATIONS

=head2 goal

Type: belongs_to

Related object: L<CardioTracker::Model::Result::Goal>

=cut

__PACKAGE__->belongs_to(
  "goal",
  "CardioTracker::Model::Result::Goal",
  { id => "goal_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user

Type: belongs_to

Related object: L<CardioTracker::Model::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "CardioTracker::Model::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user_goal_activities

Type: has_many

Related object: L<CardioTracker::Model::Result::UserGoalActivity>

=cut

__PACKAGE__->has_many(
  "user_goal_activities",
  "CardioTracker::Model::Result::UserGoalActivity",
  { "foreign.user_goal_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 activities

Type: many_to_many

Composing rels: L</user_goal_activities> -> activity

=cut

__PACKAGE__->many_to_many("activities", "user_goal_activities", "activity");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-07-26 11:48:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JO9cPvYS6JXnenaXi6yh2A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

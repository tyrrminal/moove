#<<<
use utf8;
package Moove::Model::Result::Workout;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::Workout

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

=head1 TABLE: C<Workout>

=cut

__PACKAGE__->table("Workout");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 75

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 75 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 activities

Type: has_many

Related object: L<Moove::Model::Result::Activity>

=cut

__PACKAGE__->has_many(
  "activities",
  "Moove::Model::Result::Activity",
  { "foreign.workout_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user

Type: belongs_to

Related object: L<Moove::Model::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Moove::Model::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user_goal_fulfillment_workouts

Type: has_many

Related object: L<Moove::Model::Result::UserGoalFulfillmentWorkout>

=cut

__PACKAGE__->has_many(
  "user_goal_fulfillment_workouts",
  "Moove::Model::Result::UserGoalFulfillmentWorkout",
  { "foreign.workout_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_goal_fulfillments

Type: many_to_many

Composing rels: L</user_goal_fulfillment_workouts> -> user_goal_fulfillment

=cut

__PACKAGE__->many_to_many(
  "user_goal_fulfillments",
  "user_goal_fulfillment_workouts",
  "user_goal_fulfillment",
);
#>>>
use v5.38;

# Created by DBIx::Class::Schema::Loader v0.07051 @ 2023-08-14 09:22:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AxnbM89K8+10JUIBA3y/aw

use Class::Method::Modifiers;
use List::Util qw(max);

sub next_group_num ($self) {
  return (max(map {$_->group_num} $self->activities->all) // 0) + 1;
}

sub next_set_num ($self, $group_num) {
  return (max(map {$_->set_num} $self->activities->search({group_num => $group_num})->all) // 0) + 1;
}

around 'delete' => sub ($orig, $self, @params) {
  my $results = $self->activities->related_resultset('activity_result');
  $self->activities->delete();
  $results->delete();
  $orig->($self, @params);
};

1;

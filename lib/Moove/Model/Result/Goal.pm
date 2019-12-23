#<<<
use utf8;
package Moove::Model::Result::Goal;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::Goal

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

=head1 TABLE: C<goal>

=cut

__PACKAGE__->table("goal");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 activity_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 event_only

  data_type: 'enum'
  default_value: 'N'
  extra: {list => ["Y","N"]}
  is_nullable: 0

=head2 dimension_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 goal_comparator_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 goal_span_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 min_distance_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 max_distance_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 min_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 max_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 time

  data_type: 'time'
  is_nullable: 1

=head2 distance_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "activity_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "event_only",
  {
    data_type => "enum",
    default_value => "N",
    extra => { list => ["Y", "N"] },
    is_nullable => 0,
  },
  "dimension_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "goal_comparator_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "goal_span_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "min_distance_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "max_distance_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "min_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "max_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "time",
  { data_type => "time", is_nullable => 1 },
  "distance_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_UNIQUE>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name_UNIQUE", ["name"]);

=head1 RELATIONS

=head2 activity_type

Type: belongs_to

Related object: L<Moove::Model::Result::ActivityType>

=cut

__PACKAGE__->belongs_to(
  "activity_type",
  "Moove::Model::Result::ActivityType",
  { id => "activity_type_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 dimension

Type: belongs_to

Related object: L<Moove::Model::Result::Dimension>

=cut

__PACKAGE__->belongs_to(
  "dimension",
  "Moove::Model::Result::Dimension",
  { id => "dimension_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 distance

Type: belongs_to

Related object: L<Moove::Model::Result::Distance>

=cut

__PACKAGE__->belongs_to(
  "distance",
  "Moove::Model::Result::Distance",
  { id => "distance_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 goal_comparator

Type: belongs_to

Related object: L<Moove::Model::Result::GoalComparator>

=cut

__PACKAGE__->belongs_to(
  "goal_comparator",
  "Moove::Model::Result::GoalComparator",
  { id => "goal_comparator_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 goal_span

Type: belongs_to

Related object: L<Moove::Model::Result::GoalSpan>

=cut

__PACKAGE__->belongs_to(
  "goal_span",
  "Moove::Model::Result::GoalSpan",
  { id => "goal_span_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 max_distance

Type: belongs_to

Related object: L<Moove::Model::Result::Distance>

=cut

__PACKAGE__->belongs_to(
  "max_distance",
  "Moove::Model::Result::Distance",
  { id => "max_distance_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 min_distance

Type: belongs_to

Related object: L<Moove::Model::Result::Distance>

=cut

__PACKAGE__->belongs_to(
  "min_distance",
  "Moove::Model::Result::Distance",
  { id => "min_distance_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 user_goals

Type: has_many

Related object: L<Moove::Model::Result::UserGoal>

=cut

__PACKAGE__->has_many(
  "user_goals",
  "Moove::Model::Result::UserGoal",
  { "foreign.goal_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-02 13:17:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:d5zQSpTEOQSM7l3Fr9sIKw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
sub is_pr {
  shift->goal_comparator->is_superlative;
}

1;

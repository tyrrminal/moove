use utf8;
package CardioTracker::Model::Result::GoalComparator;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::GoalComparator

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

=head1 TABLE: C<goal_comparator>

=cut

__PACKAGE__->table("goal_comparator");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 superlative

  data_type: 'enum'
  default_value: 'N'
  extra: {list => ["Y","N"]}
  is_nullable: 1

=head2 operator

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "superlative",
  {
    data_type => "enum",
    default_value => "N",
    extra => { list => ["Y", "N"] },
    is_nullable => 1,
  },
  "operator",
  { data_type => "varchar", is_nullable => 0, size => 45 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<operator_UNIQUE>

=over 4

=item * L</operator>

=back

=cut

__PACKAGE__->add_unique_constraint("operator_UNIQUE", ["operator"]);

=head1 RELATIONS

=head2 goals

Type: has_many

Related object: L<CardioTracker::Model::Result::Goal>

=cut

__PACKAGE__->has_many(
  "goals",
  "CardioTracker::Model::Result::Goal",
  { "foreign.goal_comparator_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-07-26 11:48:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6dl6Z/RL/DrB/GnNXC454Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub is_superlative {
  return shift->superlative eq 'Y';
}

sub order_by {
  return shift->operator eq 'maximum' ? '-desc' : '-asc';
}

1;

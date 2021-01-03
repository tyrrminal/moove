#<<<
use utf8;
package Moove::Model::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::User

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

=head1 TABLE: C<User>

=cut

__PACKAGE__->table("User");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 person_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 last_login

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "person_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "last_login",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<username_UNIQUE>

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->add_unique_constraint("username_UNIQUE", ["username"]);

=head1 RELATIONS

=head2 goals

Type: has_many

Related object: L<Moove::Model::Result::Goal>

=cut

__PACKAGE__->has_many(
  "goals",
  "Moove::Model::Result::Goal",
  { "foreign.owner_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person

Type: belongs_to

Related object: L<Moove::Model::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "person",
  "Moove::Model::Result::Person",
  { id => "person_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user_event_activities

Type: has_many

Related object: L<Moove::Model::Result::UserEventActivity>

=cut

__PACKAGE__->has_many(
  "user_event_activities",
  "Moove::Model::Result::UserEventActivity",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_goals

Type: has_many

Related object: L<Moove::Model::Result::UserGoal>

=cut

__PACKAGE__->has_many(
  "user_goals",
  "Moove::Model::Result::UserGoal",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 workouts

Type: has_many

Related object: L<Moove::Model::Result::Workout>

=cut

__PACKAGE__->has_many(
  "workouts",
  "Moove::Model::Result::Workout",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-03 10:58:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:i7j6jbSKv3cWGLSQghuydw


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->has_many(
  "cumulative_totals", "Moove::Model::Result::CumulativeTotal",
  {"foreign.user_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

use experimental qw(signatures);

sub is_guest($self) {
  return $self->id < 1;
}

1;

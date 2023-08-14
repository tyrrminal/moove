#<<<
use utf8;
package Moove::Model::Result::BaseActivityType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::BaseActivityType

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

=head1 TABLE: C<BaseActivityType>

=cut

__PACKAGE__->table("BaseActivityType");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 has_repeats

  data_type: 'enum'
  default_value: 'N'
  extra: {list => ["Y","N"]}
  is_nullable: 0

=head2 has_distance

  data_type: 'enum'
  default_value: 'N'
  extra: {list => ["Y","N"]}
  is_nullable: 0

=head2 has_duration

  data_type: 'enum'
  default_value: 'N'
  extra: {list => ["Y","N"]}
  is_nullable: 0

=head2 has_pace

  data_type: 'enum'
  default_value: 'N'
  extra: {list => ["Y","N"]}
  is_nullable: 0

=head2 has_speed

  data_type: 'enum'
  default_value: 'N'
  extra: {list => ["Y","N"]}
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
  "description",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "has_repeats",
  {
    data_type => "enum",
    default_value => "N",
    extra => { list => ["Y", "N"] },
    is_nullable => 0,
  },
  "has_distance",
  {
    data_type => "enum",
    default_value => "N",
    extra => { list => ["Y", "N"] },
    is_nullable => 0,
  },
  "has_duration",
  {
    data_type => "enum",
    default_value => "N",
    extra => { list => ["Y", "N"] },
    is_nullable => 0,
  },
  "has_pace",
  {
    data_type => "enum",
    default_value => "N",
    extra => { list => ["Y", "N"] },
    is_nullable => 0,
  },
  "has_speed",
  {
    data_type => "enum",
    default_value => "N",
    extra => { list => ["Y", "N"] },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<description_UNIQUE>

=over 4

=item * L</description>

=back

=cut

__PACKAGE__->add_unique_constraint("description_UNIQUE", ["description"]);

=head1 RELATIONS

=head2 activity_types

Type: has_many

Related object: L<Moove::Model::Result::ActivityType>

=cut

__PACKAGE__->has_many(
  "activity_types",
  "Moove::Model::Result::ActivityType",
  { "foreign.base_activity_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>
use v5.38;

# Created by DBIx::Class::Schema::Loader v0.07051 @ 2023-08-14 09:22:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:i2vb9vPkBut4dPNA5SIJHQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
use Class::Method::Modifiers;

around [qw(has_distance has_duration has_repeats has_pace has_speed)] => sub ($orig, $self, $value = undef) {
  if (defined($value)) {
    $value = $self->$orig($value ? 'Y' : 'N');
  } else {
    $value = $self->$orig();
  }
  return $value eq 'Y';
};

sub activity_type_ids ($self) {
  $self->activity_types->get_column('id')->all;
}

1;

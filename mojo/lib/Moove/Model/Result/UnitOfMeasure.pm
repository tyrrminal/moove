#<<<
use utf8;
package Moove::Model::Result::UnitOfMeasure;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::UnitOfMeasure

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

=head1 TABLE: C<UnitOfMeasure>

=cut

__PACKAGE__->table("UnitOfMeasure");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 abbreviation

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 normalization_factor

  data_type: 'decimal'
  extra: {unsigned => 1}
  is_nullable: 0
  size: [20,10]

=head2 inverted

  data_type: 'enum'
  default_value: 'N'
  extra: {list => ["Y","N"]}
  is_nullable: 0

=head2 normal_unit_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
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
  "name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "abbreviation",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "normalization_factor",
  {
    data_type => "decimal",
    extra => { unsigned => 1 },
    is_nullable => 0,
    size => [20, 10],
  },
  "inverted",
  {
    data_type => "enum",
    default_value => "N",
    extra => { list => ["Y", "N"] },
    is_nullable => 0,
  },
  "normal_unit_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
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

=head2 C<abbreviation_UNIQUE>

=over 4

=item * L</abbreviation>

=back

=cut

__PACKAGE__->add_unique_constraint("abbreviation_UNIQUE", ["abbreviation"]);

=head2 C<name_UNIQUE>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name_UNIQUE", ["name"]);

=head1 RELATIONS

=head2 distances

Type: has_many

Related object: L<Moove::Model::Result::Distance>

=cut

__PACKAGE__->has_many(
  "distances",
  "Moove::Model::Result::Distance",
  { "foreign.unit_of_measure_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 normal_unit

Type: belongs_to

Related object: L<Moove::Model::Result::UnitOfMeasure>

=cut

__PACKAGE__->belongs_to(
  "normal_unit",
  "Moove::Model::Result::UnitOfMeasure",
  { id => "normal_unit_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 units_of_measure

Type: has_many

Related object: L<Moove::Model::Result::UnitOfMeasure>

=cut

__PACKAGE__->has_many(
  "units_of_measure",
  "Moove::Model::Result::UnitOfMeasure",
  { "foreign.normal_unit_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>
use v5.36;

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-09 12:32:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oDuWZm7q6ixIj4W8lH2B+g


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use Class::Method::Modifiers;

sub is_normal_unit ($self) {
  return !defined($self->normal_unit_id);
}

sub normalized_unit ($self) {
  return $self->is_normal_unit ? $self : $self->normal_unit;
}

around [qw(inverted)] => sub ($orig, $self, $value = undef) {
  if (defined($value)) {
    $value = $self->$orig($value ? 'Y' : 'N');
  } else {
    $value = $self->$orig();
  }
  return $value eq 'Y';
};

1;

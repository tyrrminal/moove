#<<<
use utf8;
package Moove::Model::Result::UnitOfMeasureType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::UnitOfMeasureType

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

=head1 TABLE: C<UnitOfMeasureType>

=cut

__PACKAGE__->table("UnitOfMeasureType");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 50

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
  { data_type => "varchar", is_nullable => 0, size => 50 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<unit_of_measure_type_description_uniq>

=over 4

=item * L</description>

=back

=cut

__PACKAGE__->add_unique_constraint("unit_of_measure_type_description_uniq", ["description"]);

=head1 RELATIONS

=head2 units_of_measure

Type: has_many

Related object: L<Moove::Model::Result::UnitOfMeasure>

=cut

__PACKAGE__->has_many(
  "units_of_measure",
  "Moove::Model::Result::UnitOfMeasure",
  { "foreign.unit_of_measure_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>
use v5.36;

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-28 10:53:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lmj9n4HwO02HR8y96IA0zQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

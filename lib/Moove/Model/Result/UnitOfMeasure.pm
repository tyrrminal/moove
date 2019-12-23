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

=head1 TABLE: C<unit_of_measure>

=cut

__PACKAGE__->table("unit_of_measure");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 dimension_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 uom

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 abbreviation

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 conversion_factor

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "dimension_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "uom",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "abbreviation",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "conversion_factor",
  { data_type => "varchar", is_nullable => 0, size => 45 },
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

=head2 C<uom_UNIQUE>

=over 4

=item * L</uom>

=back

=cut

__PACKAGE__->add_unique_constraint("uom_UNIQUE", ["uom"]);

=head1 RELATIONS

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

=head2 distances

Type: has_many

Related object: L<Moove::Model::Result::Distance>

=cut

__PACKAGE__->has_many(
  "distances",
  "Moove::Model::Result::Distance",
  { "foreign.uom" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-02 13:17:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EWqdBdIdwopXN50hGtNQgg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
sub to_hash {
  my $self = shift;

  return {
    id                   => $self->id,
    unit                 => $self->uom,
    abbreviation         => $self->abbreviation,
    normalization_factor => $self->conversion_factor
  };
}

1;

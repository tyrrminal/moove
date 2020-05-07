#<<<
use utf8;
package Moove::Model::Result::Distance;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::Distance

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

=head1 TABLE: C<Distance>

=cut

__PACKAGE__->table("Distance");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 value

  data_type: 'decimal'
  is_nullable: 0
  size: [7,3]

=head2 unit_of_measure_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
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
  "value",
  { data_type => "decimal", is_nullable => 0, size => [7, 3] },
  "unit_of_measure_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 cardio_activity_sets

Type: has_many

Related object: L<Moove::Model::Result::CardioActivitySet>

=cut

__PACKAGE__->has_many(
  "cardio_activity_sets",
  "Moove::Model::Result::CardioActivitySet",
  { "foreign.distance_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 cardio_event_activities

Type: has_many

Related object: L<Moove::Model::Result::CardioEventActivity>

=cut

__PACKAGE__->has_many(
  "cardio_event_activities",
  "Moove::Model::Result::CardioEventActivity",
  { "foreign.distance_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 unit_of_measure

Type: belongs_to

Related object: L<Moove::Model::Result::UnitOfMeasure>

=cut

__PACKAGE__->belongs_to(
  "unit_of_measure",
  "Moove::Model::Result::UnitOfMeasure",
  { id => "unit_of_measure_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-05-07 12:23:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dBUyU4TxcJqZhJYDRxc79g


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub description {
  my $self = shift;

  return sprintf("%.2f %s", $self->value, $self->uom->abbreviation);
}

sub description_normalized {
  my $self = shift;

  return sprintf("%.2f %s", $self->normalized_value, $self->normalized_unit->abbreviation);
}

sub normalized_unit {
  my $self = shift;

  return $self->result_source->schema->resultset('UnitOfMeasure')->normalization_unit($self->uom->dimension->description);
}

sub normalized_value {
  my $self = shift;

  return $self->value * $self->uom->conversion_factor;
}

1;

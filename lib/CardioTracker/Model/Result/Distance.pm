#<<<
use utf8;
package CardioTracker::Model::Result::Distance;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::Distance

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

=head1 TABLE: C<distance>

=cut

__PACKAGE__->table("distance");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 value

  data_type: 'decimal'
  is_nullable: 0
  size: [7,3]

=head2 uom

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "value",
  { data_type => "decimal", is_nullable => 0, size => [7, 3] },
  "uom",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<distance_value_uom_uniq_idx>

=over 4

=item * L</value>

=item * L</uom>

=back

=cut

__PACKAGE__->add_unique_constraint("distance_value_uom_uniq_idx", ["value", "uom"]);

=head1 RELATIONS

=head2 activities

Type: has_many

Related object: L<CardioTracker::Model::Result::Activity>

=cut

__PACKAGE__->has_many(
  "activities",
  "CardioTracker::Model::Result::Activity",
  { "foreign.distance_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events

Type: has_many

Related object: L<CardioTracker::Model::Result::Event>

=cut

__PACKAGE__->has_many(
  "events",
  "CardioTracker::Model::Result::Event",
  { "foreign.distance_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 goal_distances

Type: has_many

Related object: L<CardioTracker::Model::Result::Goal>

=cut

__PACKAGE__->has_many(
  "goal_distances",
  "CardioTracker::Model::Result::Goal",
  { "foreign.distance_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 goal_max_distances

Type: has_many

Related object: L<CardioTracker::Model::Result::Goal>

=cut

__PACKAGE__->has_many(
  "goal_max_distances",
  "CardioTracker::Model::Result::Goal",
  { "foreign.max_distance_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 goal_min_distances

Type: has_many

Related object: L<CardioTracker::Model::Result::Goal>

=cut

__PACKAGE__->has_many(
  "goal_min_distances",
  "CardioTracker::Model::Result::Goal",
  { "foreign.min_distance_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 uom

Type: belongs_to

Related object: L<CardioTracker::Model::Result::UnitOfMeasure>

=cut

__PACKAGE__->belongs_to(
  "uom",
  "CardioTracker::Model::Result::UnitOfMeasure",
  { id => "uom" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-02 13:17:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VYV+UDqB/3jFi2X0FNF7aQ


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

  return $self->result_source->schema->resultset('UnitOfMeasure')->normalization_unit('distance');
}

sub normalized_value {
  my $self = shift;

  return $self->value * $self->uom->conversion_factor;
}

sub to_hash {
  my $self = shift;

  return {
    quantity => {
      value => $self->value,
      units => $self->uom->to_hash
    },
    normalized_quantity => {
      value => $self->normalized_value,
      units => $self->normalized_unit->to_hash
    }
  };
}

1;

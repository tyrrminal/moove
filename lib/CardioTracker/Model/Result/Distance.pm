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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-11-11 14:38:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LE0sM3xOJcthfNCwLTMNDg


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub description {
  my $self=shift;

  return sprintf("%.2f %s", $self->value, $self->uom->abbreviation)
}

1;

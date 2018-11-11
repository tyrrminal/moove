use utf8;
package CardioTracker::Model::Result::UnitOfMeasure;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::UnitOfMeasure

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

=head2 uom

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 abbreviation

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 conversion_factor

  data_type: 'float'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "uom",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "abbreviation",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "conversion_factor",
  { data_type => "float", is_nullable => 0 },
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

=head2 distances

Type: has_many

Related object: L<CardioTracker::Model::Result::Distance>

=cut

__PACKAGE__->has_many(
  "distances",
  "CardioTracker::Model::Result::Distance",
  { "foreign.uom" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-11-11 14:38:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6nSqhmKRIq6f081MQfsE3Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

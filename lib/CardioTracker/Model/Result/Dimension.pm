#<<<
use utf8;
package CardioTracker::Model::Result::Dimension;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::Dimension

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

=head1 TABLE: C<dimension>

=cut

__PACKAGE__->table("dimension");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 45 },
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

=head2 goals

Type: has_many

Related object: L<CardioTracker::Model::Result::Goal>

=cut

__PACKAGE__->has_many(
  "goals",
  "CardioTracker::Model::Result::Goal",
  { "foreign.dimension_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 units_of_measure

Type: has_many

Related object: L<CardioTracker::Model::Result::UnitOfMeasure>

=cut

__PACKAGE__->has_many(
  "units_of_measure",
  "CardioTracker::Model::Result::UnitOfMeasure",
  { "foreign.dimension_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-02 13:17:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0Jtg/SYehaBMqE42Tlukfw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
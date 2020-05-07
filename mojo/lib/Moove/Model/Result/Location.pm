#<<<
use utf8;
package Moove::Model::Result::Location;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::Location

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

=head1 TABLE: C<Location>

=cut

__PACKAGE__->table("Location");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 latitude

  data_type: 'decimal'
  is_nullable: 0
  size: [9,6]

=head2 longitude

  data_type: 'decimal'
  is_nullable: 0
  size: [9,6]

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "latitude",
  { data_type => "decimal", is_nullable => 0, size => [9, 6] },
  "longitude",
  { data_type => "decimal", is_nullable => 0, size => [9, 6] },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 activity_points

Type: has_many

Related object: L<Moove::Model::Result::ActivityPoint>

=cut

__PACKAGE__->has_many(
  "activity_points",
  "Moove::Model::Result::ActivityPoint",
  { "foreign.location_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-05-01 15:48:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ani3eVt7SaBxAQy+5P2plA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

1;

#<<<
use utf8;
package CardioTracker::Model::Result::Location;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::Location

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

=head1 TABLE: C<location>

=cut

__PACKAGE__->table("location");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
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
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
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

Related object: L<CardioTracker::Model::Result::ActivityPoint>

=cut

__PACKAGE__->has_many(
  "activity_points",
  "CardioTracker::Model::Result::ActivityPoint",
  { "foreign.location_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users

Type: has_many

Related object: L<CardioTracker::Model::Result::User>

=cut

__PACKAGE__->has_many(
  "users",
  "CardioTracker::Model::Result::User",
  { "foreign.location_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-02 13:17:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JJl+WdE96CwGXQPZ2k7KzA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
sub to_hash {
  my $self = shift;

  return {
    id        => $self->id,
    latitude  => $self->latitude,
    longitude => $self->longitude
    };
}
1;

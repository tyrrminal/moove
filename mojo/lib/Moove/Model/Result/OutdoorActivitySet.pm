#<<<
use utf8;
package Moove::Model::Result::OutdoorActivitySet;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::OutdoorActivitySet

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

=head1 TABLE: C<OutdoorActivitySet>

=cut

__PACKAGE__->table("OutdoorActivitySet");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 activity_set_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 temperature

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "activity_set_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "temperature",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
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
  { "foreign.outdoor_activity_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 activity_set

Type: belongs_to

Related object: L<Moove::Model::Result::ActivitySet>

=cut

__PACKAGE__->belongs_to(
  "activity_set",
  "Moove::Model::Result::ActivitySet",
  { id => "activity_set_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-05-07 12:23:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:70/wWaPNc+60AOD0FYINIQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

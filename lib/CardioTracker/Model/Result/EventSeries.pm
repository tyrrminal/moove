#<<<
use utf8;
package CardioTracker::Model::Result::EventSeries;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::EventSeries

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

=head1 TABLE: C<event_series>

=cut

__PACKAGE__->table("event_series");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 year

  data_type: 'integer'
  is_nullable: 0

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "year",
  { data_type => "integer", is_nullable => 0 },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 512 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_year_uniq_idx>

=over 4

=item * L</name>

=item * L</year>

=back

=cut

__PACKAGE__->add_unique_constraint("name_year_uniq_idx", ["name", "year"]);

=head1 RELATIONS

=head2 event_group_series

Type: has_many

Related object: L<CardioTracker::Model::Result::EventGroupSeries>

=cut

__PACKAGE__->has_many(
  "event_group_series",
  "CardioTracker::Model::Result::EventGroupSeries",
  { "foreign.event_series_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_groups

Type: many_to_many

Composing rels: L</event_group_series> -> event_group

=cut

__PACKAGE__->many_to_many("event_groups", "event_group_series", "event_group");
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-02 13:17:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:g/qmoxucHA/CRMEsB5KWLA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub to_hash {
  my $self = shift;

  return {
    id   => $self->id,
    name => $self->name,
    year => $self->year
  };
}

1;

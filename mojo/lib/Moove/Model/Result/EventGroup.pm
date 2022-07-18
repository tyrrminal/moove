#<<<
use utf8;
package Moove::Model::Result::EventGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::EventGroup

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

=head1 TABLE: C<EventGroup>

=cut

__PACKAGE__->table("EventGroup");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url

  data_type: 'text'
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 year

  data_type: 'smallint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "url",
  { data_type => "text", is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "year",
  { data_type => "smallint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 event_series_events

Type: has_many

Related object: L<Moove::Model::Result::EventSeriesEvent>

=cut

__PACKAGE__->has_many(
  "event_series_events",
  "Moove::Model::Result::EventSeriesEvent",
  { "foreign.event_group_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events_2s

Type: has_many

Related object: L<Moove::Model::Result::Event>

=cut

__PACKAGE__->has_many(
  "events_2s",
  "Moove::Model::Result::Event",
  { "foreign.event_group_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events

Type: many_to_many

Composing rels: L</event_series_events> -> event

=cut

__PACKAGE__->many_to_many("events", "event_series_events", "event");
#>>>
use v5.36;

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-09 12:32:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Vboj/MPZrJkeu84eun2VRw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
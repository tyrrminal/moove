#<<<
use utf8;
package Moove::Model::Result::EventSeriesEvent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::EventSeriesEvent

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

=head1 TABLE: C<EventSeriesEvent>

=cut

__PACKAGE__->table("EventSeriesEvent");

=head1 ACCESSORS

=head2 event_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 event_series_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "event_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "event_series_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</event_id>

=item * L</event_series_id>

=back

=cut

__PACKAGE__->set_primary_key("event_id", "event_series_id");

=head1 RELATIONS

=head2 event

Type: belongs_to

Related object: L<Moove::Model::Result::Event>

=cut

__PACKAGE__->belongs_to(
  "event",
  "Moove::Model::Result::Event",
  { id => "event_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event_series

Type: belongs_to

Related object: L<Moove::Model::Result::EventGroup>

=cut

__PACKAGE__->belongs_to(
  "event_series",
  "Moove::Model::Result::EventGroup",
  { id => "event_series_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>
use v5.38;

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-08-02 10:06:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:avXpbiKiyjz1rhd3cC0SOA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

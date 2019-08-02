#<<<
use utf8;
package CardioTracker::Model::Result::EventGroupSeries;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::EventGroupSeries

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

=head1 TABLE: C<event_group_series>

=cut

__PACKAGE__->table("event_group_series");

=head1 ACCESSORS

=head2 event_group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 event_series_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "event_group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "event_series_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</event_group_id>

=item * L</event_series_id>

=back

=cut

__PACKAGE__->set_primary_key("event_group_id", "event_series_id");

=head1 RELATIONS

=head2 event_group

Type: belongs_to

Related object: L<CardioTracker::Model::Result::EventGroup>

=cut

__PACKAGE__->belongs_to(
  "event_group",
  "CardioTracker::Model::Result::EventGroup",
  { id => "event_group_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event_series

Type: belongs_to

Related object: L<CardioTracker::Model::Result::EventSeries>

=cut

__PACKAGE__->belongs_to(
  "event_series",
  "CardioTracker::Model::Result::EventSeries",
  { id => "event_series_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-02 13:17:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:iBRmgDmnhXQZBpDZxZ7IUA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

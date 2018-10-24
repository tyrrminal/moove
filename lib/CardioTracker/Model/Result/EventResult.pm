use utf8;
package CardioTracker::Model::Result::EventResult;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::EventResult

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::Relationship::Predicate>

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("Relationship::Predicate", "InflateColumn::DateTime");

=head1 TABLE: C<event_result>

=cut

__PACKAGE__->table("event_result");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 result_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 place

  data_type: 'integer'
  is_nullable: 1

=head2 event_result_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "result_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "place",
  { data_type => "integer", is_nullable => 1 },
  "event_result_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 event_result_type

Type: belongs_to

Related object: L<CardioTracker::Model::Result::EventResultType>

=cut

__PACKAGE__->belongs_to(
  "event_result_type",
  "CardioTracker::Model::Result::EventResultType",
  { id => "event_result_type_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 result

Type: belongs_to

Related object: L<CardioTracker::Model::Result::Result>

=cut

__PACKAGE__->belongs_to(
  "result",
  "CardioTracker::Model::Result::Result",
  { id => "result_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-10-15 20:45:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bVeZnwqn0NWvKlZoTB9UTA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

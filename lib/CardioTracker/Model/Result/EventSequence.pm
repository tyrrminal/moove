use utf8;
package CardioTracker::Model::Result::EventSequence;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::EventSequence

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

=head1 TABLE: C<event_sequence>

=cut

__PACKAGE__->table("event_sequence");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 512 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 event_groups

Type: has_many

Related object: L<CardioTracker::Model::Result::EventGroup>

=cut

__PACKAGE__->has_many(
  "event_groups",
  "CardioTracker::Model::Result::EventGroup",
  { "foreign.event_sequence_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-07-27 12:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:s2iWL8mvRVvwOxlybDCySA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

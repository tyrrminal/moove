#<<<
use utf8;
package Moove::Model::Result::CardioEventParticipant;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::CardioEventParticipant

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

=head1 TABLE: C<CardioEventParticipant>

=cut

__PACKAGE__->table("CardioEventParticipant");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 event_participant_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 cardio_activity_result_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "event_participant_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "cardio_activity_result_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 cardio_activity_result

Type: belongs_to

Related object: L<Moove::Model::Result::CardioActivityResult>

=cut

__PACKAGE__->belongs_to(
  "cardio_activity_result",
  "Moove::Model::Result::CardioActivityResult",
  { id => "cardio_activity_result_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event_participant

Type: belongs_to

Related object: L<Moove::Model::Result::EventParticipant>

=cut

__PACKAGE__->belongs_to(
  "event_participant",
  "Moove::Model::Result::EventParticipant",
  { id => "event_participant_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-05-01 15:48:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dQIk1gxe3bA0ndlwyoTz6g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

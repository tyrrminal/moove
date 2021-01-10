#<<<
use utf8;
package Moove::Model::Result::EventRegistration;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::EventRegistration

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

=head1 TABLE: C<EventRegistration>

=cut

__PACKAGE__->table("EventRegistration");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 event_activity_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 registration_number

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "event_activity_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "registration_number",
  { data_type => "varchar", is_nullable => 1, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<event_activity_registration_number_UNIQUE>

=over 4

=item * L</event_activity_id>

=item * L</registration_number>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "event_activity_registration_number_UNIQUE",
  ["event_activity_id", "registration_number"],
);

=head1 RELATIONS

=head2 event_activity

Type: belongs_to

Related object: L<Moove::Model::Result::EventActivity>

=cut

__PACKAGE__->belongs_to(
  "event_activity",
  "Moove::Model::Result::EventActivity",
  { id => "event_activity_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event_participants

Type: has_many

Related object: L<Moove::Model::Result::EventParticipant>

=cut

__PACKAGE__->has_many(
  "event_participants",
  "Moove::Model::Result::EventParticipant",
  { "foreign.event_registration_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_event_activities

Type: has_many

Related object: L<Moove::Model::Result::UserEventActivity>

=cut

__PACKAGE__->has_many(
  "user_event_activities",
  "Moove::Model::Result::UserEventActivity",
  { "foreign.event_registration_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-09 17:03:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zUXt5F1Ppmv88DVKVINJRQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

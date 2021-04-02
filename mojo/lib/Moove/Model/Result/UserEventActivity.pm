#<<<
use utf8;
package Moove::Model::Result::UserEventActivity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::UserEventActivity

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

=head1 TABLE: C<UserEventActivity>

=cut

__PACKAGE__->table("UserEventActivity");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 event_registration_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 visibility_type_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 date_registered

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 registration_fee

  data_type: 'decimal'
  is_nullable: 1
  size: [6,2]

=head2 fundraising_requirement

  data_type: 'decimal'
  is_nullable: 1
  size: [6,2]

=head2 activity_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
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
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "event_registration_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "visibility_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "date_registered",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "registration_fee",
  { data_type => "decimal", is_nullable => 1, size => [6, 2] },
  "fundraising_requirement",
  { data_type => "decimal", is_nullable => 1, size => [6, 2] },
  "activity_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 activity

Type: belongs_to

Related object: L<Moove::Model::Result::Activity>

=cut

__PACKAGE__->belongs_to(
  "activity",
  "Moove::Model::Result::Activity",
  { id => "activity_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 donations

Type: has_many

Related object: L<Moove::Model::Result::Donation>

=cut

__PACKAGE__->has_many(
  "donations",
  "Moove::Model::Result::Donation",
  { "foreign.user_event_activity_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_registration

Type: belongs_to

Related object: L<Moove::Model::Result::EventRegistration>

=cut

__PACKAGE__->belongs_to(
  "event_registration",
  "Moove::Model::Result::EventRegistration",
  { id => "event_registration_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user

Type: belongs_to

Related object: L<Moove::Model::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Moove::Model::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 visibility_type

Type: belongs_to

Related object: L<Moove::Model::Result::VisibilityType>

=cut

__PACKAGE__->belongs_to(
  "visibility_type",
  "Moove::Model::Result::VisibilityType",
  { id => "visibility_type_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>
use experimental qw(signatures postderef);

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-04-02 11:05:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FzzdfZWDOFC+snDTD95TiA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub sequence {
  my $self = shift;

  return $self->result_source->schema->resultset('EventRegistration')->in_sequence($self->event->event_group->event_sequence_id)
    ->for_user($self->user);
}

1;

use utf8;
package CardioTracker::Model::Result::Donation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::Donation

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

=head1 TABLE: C<donation>

=cut

__PACKAGE__->table("donation");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 event_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 amount

  data_type: 'decimal'
  is_nullable: 0
  size: [6,2]

=head2 date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 person_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 address_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "event_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "amount",
  { data_type => "decimal", is_nullable => 0, size => [6, 2] },
  "date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "person_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "address_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 address

Type: belongs_to

Related object: L<CardioTracker::Model::Result::Address>

=cut

__PACKAGE__->belongs_to(
  "address",
  "CardioTracker::Model::Result::Address",
  { id => "address_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event_registration

Type: belongs_to

Related object: L<CardioTracker::Model::Result::EventRegistration>

=cut

__PACKAGE__->belongs_to(
  "event_registration",
  "CardioTracker::Model::Result::EventRegistration",
  { event_id => "event_id", user_id => "user_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 person

Type: belongs_to

Related object: L<CardioTracker::Model::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "person",
  "CardioTracker::Model::Result::Person",
  { id => "person_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-01-26 10:01:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UfCWmGtpxVTZjvTWuSmFqg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

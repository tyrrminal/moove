#<<<
use utf8;
package Moove::Model::Result::Address;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::Address

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

=head1 TABLE: C<Address>

=cut

__PACKAGE__->table("Address");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 street1

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 street2

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 city

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 state

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 zip

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 country

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 phone

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "street1",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "street2",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "city",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "state",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "zip",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "country",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "phone",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 200 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 donations

Type: has_many

Related object: L<Moove::Model::Result::Donation>

=cut

__PACKAGE__->has_many(
  "donations",
  "Moove::Model::Result::Donation",
  { "foreign.address_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_participants

Type: has_many

Related object: L<Moove::Model::Result::EventParticipant>

=cut

__PACKAGE__->has_many(
  "event_participants",
  "Moove::Model::Result::EventParticipant",
  { "foreign.address_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events

Type: has_many

Related object: L<Moove::Model::Result::Event>

=cut

__PACKAGE__->has_many(
  "events",
  "Moove::Model::Result::Event",
  { "foreign.address_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>
use v5.38;

# Created by DBIx::Class::Schema::Loader v0.07051 @ 2023-08-14 09:22:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GwPlasgzk9BbHSxw6fGlKw

# You can replace this text with custom code or comments, and it will be preserved on regeneration

use Readonly;

Readonly::Scalar my $null_address => 8;

sub is_empty {
  return (shift->id == $null_address);
}

1;

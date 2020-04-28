#<<<
use utf8;
package Moove::Model::Result::Participant;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::Participant

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

=head1 TABLE: C<participant>

=cut

__PACKAGE__->table("participant");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 result_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 bib_no

  data_type: 'integer'
  is_nullable: 1

=head2 division_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 age

  data_type: 'integer'
  is_nullable: 1

=head2 person_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 gender_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 address_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "result_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "bib_no",
  { data_type => "integer", is_nullable => 1 },
  "division_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "age",
  { data_type => "integer", is_nullable => 1 },
  "person_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "gender_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "address_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
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

Related object: L<Moove::Model::Result::Address>

=cut

__PACKAGE__->belongs_to(
  "address",
  "Moove::Model::Result::Address",
  { id => "address_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 division

Type: belongs_to

Related object: L<Moove::Model::Result::Division>

=cut

__PACKAGE__->belongs_to(
  "division",
  "Moove::Model::Result::Division",
  { id => "division_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 gender

Type: belongs_to

Related object: L<Moove::Model::Result::Gender>

=cut

__PACKAGE__->belongs_to(
  "gender",
  "Moove::Model::Result::Gender",
  { id => "gender_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 person

Type: belongs_to

Related object: L<Moove::Model::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "person",
  "Moove::Model::Result::Person",
  { id => "person_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 result

Type: belongs_to

Related object: L<Moove::Model::Result::Result>

=cut

__PACKAGE__->belongs_to(
  "result",
  "Moove::Model::Result::Result",
  { id => "result_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-04-28 15:46:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2mJ3t+yhLwGHx1dNTn3EUg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

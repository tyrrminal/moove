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

=item * L<DBIx::Class::Stash>

=back

=cut

__PACKAGE__->load_components(
  "Relationship::Predicate",
  "InflateColumn::DateTime",
  "InflateColumn::Time",
  "Stash",
);

=head1 TABLE: C<event_registration>

=cut

__PACKAGE__->table("event_registration");

=head1 ACCESSORS

=head2 event_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 fee

  data_type: 'decimal'
  is_nullable: 1
  size: [6,2]

=head2 fundraising_minimum

  data_type: 'decimal'
  is_nullable: 1
  size: [6,2]

=head2 registered

  data_type: 'enum'
  default_value: 'N'
  extra: {list => ["Y","P","N"]}
  is_nullable: 1

=head2 bib_no

  data_type: 'integer'
  is_nullable: 1

=head2 is_public

  data_type: 'enum'
  default_value: 'Y'
  extra: {list => ["Y","N"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "event_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "fee",
  { data_type => "decimal", is_nullable => 1, size => [6, 2] },
  "fundraising_minimum",
  { data_type => "decimal", is_nullable => 1, size => [6, 2] },
  "registered",
  {
    data_type => "enum",
    default_value => "N",
    extra => { list => ["Y", "P", "N"] },
    is_nullable => 1,
  },
  "bib_no",
  { data_type => "integer", is_nullable => 1 },
  "is_public",
  {
    data_type => "enum",
    default_value => "Y",
    extra => { list => ["Y", "N"] },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</event_id>

=item * L</user_id>

=back

=cut

__PACKAGE__->set_primary_key("event_id", "user_id");

=head1 RELATIONS

=head2 donations

Type: has_many

Related object: L<Moove::Model::Result::Donation>

=cut

__PACKAGE__->has_many(
  "donations",
  "Moove::Model::Result::Donation",
  {
    "foreign.event_id" => "self.event_id",
    "foreign.user_id"  => "self.user_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

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
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-04-24 13:28:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ypeb+qx9l6J8SFSJEo1mMw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
use DateTime;
use List::Util qw(sum0);

use DCS::Constants qw(:boolean);

sub sequence {
  my $self = shift;

  return $self->result_source->schema->resultset('EventRegistration')->in_sequence($self->event->event_group->event_sequence_id)
    ->for_user($self->user);
}

1;

#<<<
use utf8;
package Moove::Model::Result::EventResult;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::EventResult

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

=head1 TABLE: C<event_result>

=cut

__PACKAGE__->table("event_result");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 result_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 place

  data_type: 'integer'
  is_nullable: 0

=head2 event_result_group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "result_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "place",
  { data_type => "integer", is_nullable => 0 },
  "event_result_group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 event_result_group

Type: belongs_to

Related object: L<Moove::Model::Result::EventResultGroup>

=cut

__PACKAGE__->belongs_to(
  "event_result_group",
  "Moove::Model::Result::EventResultGroup",
  { id => "event_result_group_id" },
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:leJfzAq1VmtCzJldt/lJ/w


# You can replace this text with custom code or comments, and it will be preserved on regeneration

1;

#<<<
use utf8;
package Moove::Model::Result::UserNominalActivityRange;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::UserNominalActivityRange

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

=head1 TABLE: C<UserNominalActivityRange>

=cut

__PACKAGE__->table("UserNominalActivityRange");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 user_nominal_activity_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 rangestart

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 rangeend

  data_type: 'date'
  datetime_undef_if_invalid: 1
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
  "user_nominal_activity_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "rangestart",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "rangeend",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 user_nominal_activity

Type: belongs_to

Related object: L<Moove::Model::Result::UserNominalActivity>

=cut

__PACKAGE__->belongs_to(
  "user_nominal_activity",
  "Moove::Model::Result::UserNominalActivity",
  { id => "user_nominal_activity_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>
use experimental qw(signatures postderef);

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-04-06 16:09:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PIJkHfYI/m3CJCuqueC/Tg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

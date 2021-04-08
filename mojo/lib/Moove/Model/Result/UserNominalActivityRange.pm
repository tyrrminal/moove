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

=head2 range_start

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 range_end

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
  "range_start",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "range_end",
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

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-04-06 16:18:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZRjev5NyLvQ22JUptJtOIw
use List::Util qw(min max);

sub intersection ($self, $start, $end) {
  my ($rs, $re) = (max($start, $self->range_start), min($end, $self->range_end));
  return 0 if ($rs >= $re);
  return $rs->delta_days($re)->delta_days;
}

1;

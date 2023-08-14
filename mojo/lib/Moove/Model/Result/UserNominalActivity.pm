#<<<
use utf8;
package Moove::Model::Result::UserNominalActivity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::UserNominalActivity

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

=head1 TABLE: C<UserNominalActivity>

=cut

__PACKAGE__->table("UserNominalActivity");

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

=head2 activity_type_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 start_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 end_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 value

  data_type: 'longtext'
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
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "activity_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "start_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "end_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "value",
  { data_type => "longtext", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 activity_type

Type: belongs_to

Related object: L<Moove::Model::Result::ActivityType>

=cut

__PACKAGE__->belongs_to(
  "activity_type",
  "Moove::Model::Result::ActivityType",
  { id => "activity_type_id" },
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
use v5.38;

# Created by DBIx::Class::Schema::Loader v0.07051 @ 2023-08-14 09:22:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5Cj4APnVyyB1TGdolL4OOg
use builtin      qw(false);
use experimental qw(builtin);

use Mojo::JSON qw(decode_json);

sub _per_day ($self, $period, $v) {
  my $yl = DateTime->new(year => $self->start_date->year)->year_length;

  return $v / 7          if ($period eq 'week');
  return $v / ($yl / 12) if ($period eq 'month');
  return $v / $yl        if ($period eq 'year');
  return $v;
}

sub nominal_distance_in_range ($self, $start, $end) {
  my $schema = $self->result_source->schema;

  $start //= DateTime->from_epoch(epoch => 0);
  $end   //= DateTime->new(year => 3000, month => 1, day => 1);

  my $p = decode_json($self->value)->{distance};
  return () unless (defined($p));
  my $d    = $self->_per_day($p->{period}, $p->{value});
  my $days = ($end < $self->end_date ? $end : $self->end_date)->delta_days($start > $self->start_date ? $start : $self->start_date)
    ->in_units('days') + 1;    # Add one because the range is open-closed (does not include end date)

  my $units    = $schema->resultset('UnitOfMeasure')->find({abbreviation => $p->{units}});
  my $distance = $schema->resultset('Distance')->find_or_create_in_units($d * $days, $units, false);
  return $distance;
}

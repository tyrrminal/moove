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

=head2 year

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

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
  "year",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
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

=head2 user_nominal_activity_ranges

Type: has_many

Related object: L<Moove::Model::Result::UserNominalActivityRange>

=cut

__PACKAGE__->has_many(
  "user_nominal_activity_ranges",
  "Moove::Model::Result::UserNominalActivityRange",
  { "foreign.user_nominal_activity_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>
use v5.36;

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-09 16:32:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ha97sKhVVZO3ll0DEvEKvw
use Mojo::JSON qw(decode_json);

sub days_in_range_between_dates ($self, $start, $end = undef) {
  my $year = $self->year;
  die('Start date is required') unless (defined($start) && ref($start) eq 'DateTime');
  die('End date must be a DateTime') if (defined($end) && ref($end) ne 'DateTime');
  $end   = DateTime->new(year => $self->year + 1) unless (defined($end));
  $start = $start->clone;
  $end   = $end->clone->subtract(days => 1);
  return 1                                    if ($start->ymd eq $end->ymd);
  die('Start date must come before end date') if ($start > $end);
  die('Start date out of range') unless ($year == $start->year);
  die('End date out of range')   unless (abs($year - $end->year) <= 1);
  $end->add(days => 1) if ($end < DateTime->today);

  my $days;
  if (my @ranges = $self->user_nominal_activity_ranges->all) {
    $days += $_->intersection($start, $end) foreach (@ranges);
  } else {
    $days = $start->delta_days($end)->delta_days;
  }
  return $days;
}

sub per_day ($self) {
  my %v  = decode_json($self->value)->%*;
  my $rs = $self->result_source->schema->resultset('UnitOfMeasure');
  return {
    map {
      $_ => $self->_per_day($v{$_}->{period}, $v{$_}->{value}) * $rs->find({abbreviation => $v{$_}->{units}})->normalization_factor
      }
      keys(%v)
  };
}

sub year_length ($self) {
  return DateTime->new(year => $self->year)->year_length;
}

sub _per_day ($self, $period, $v) {
  return $v / 7                         if ($period eq 'week');
  return $v / ($self->year_length / 12) if ($period eq 'month');
  return $v / $self->year_length        if ($period eq 'year');
  return $v;
}

1;

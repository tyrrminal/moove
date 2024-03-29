#<<<
use utf8;
package Moove::Model::Result::ActivityResult;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::ActivityResult

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

=head1 TABLE: C<ActivityResult>

=cut

__PACKAGE__->table("ActivityResult");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 start_time

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 distance_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 duration

  data_type: 'time'
  is_nullable: 1

=head2 net_time

  data_type: 'time'
  is_nullable: 1

=head2 pace

  data_type: 'time'
  is_nullable: 1

=head2 speed

  data_type: 'decimal'
  is_nullable: 1
  size: [7,3]

=head2 weight

  data_type: 'decimal'
  default_value: 0.00
  is_nullable: 1
  size: [6,2]

=head2 repetitions

  data_type: 'smallint'
  is_nullable: 1

=head2 heart_rate

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 temperature

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 map_visibility_type_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 speed_to_pace

  data_type: 'time'
  is_nullable: 1

=head2 pace_to_speed

  data_type: 'decimal'
  is_nullable: 1
  size: [7,3]

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "start_time",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "distance_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "duration",
  { data_type => "time", is_nullable => 1 },
  "net_time",
  { data_type => "time", is_nullable => 1 },
  "pace",
  { data_type => "time", is_nullable => 1 },
  "speed",
  { data_type => "decimal", is_nullable => 1, size => [7, 3] },
  "weight",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 1,
    size => [6, 2],
  },
  "repetitions",
  { data_type => "smallint", is_nullable => 1 },
  "heart_rate",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "temperature",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "map_visibility_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "speed_to_pace",
  { data_type => "time", is_nullable => 1 },
  "pace_to_speed",
  { data_type => "decimal", is_nullable => 1, size => [7, 3] },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 activities

Type: has_many

Related object: L<Moove::Model::Result::Activity>

=cut

__PACKAGE__->has_many(
  "activities",
  "Moove::Model::Result::Activity",
  { "foreign.activity_result_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 activity_points

Type: has_many

Related object: L<Moove::Model::Result::ActivityPoint>

=cut

__PACKAGE__->has_many(
  "activity_points",
  "Moove::Model::Result::ActivityPoint",
  { "foreign.activity_result_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 distance

Type: belongs_to

Related object: L<Moove::Model::Result::Distance>

=cut

__PACKAGE__->belongs_to(
  "distance",
  "Moove::Model::Result::Distance",
  { id => "distance_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 event_participants

Type: has_many

Related object: L<Moove::Model::Result::EventParticipant>

=cut

__PACKAGE__->has_many(
  "event_participants",
  "Moove::Model::Result::EventParticipant",
  { "foreign.event_result_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 map_visibility_type

Type: belongs_to

Related object: L<Moove::Model::Result::VisibilityType>

=cut

__PACKAGE__->belongs_to(
  "map_visibility_type",
  "Moove::Model::Result::VisibilityType",
  { id => "map_visibility_type_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);
#>>>
use v5.38;

# Created by DBIx::Class::Schema::Loader v0.07051 @ 2023-08-14 09:22:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ebF4/vrsIxlyhvHA7xNi6g

use Moove::Util::Unit::Conversion qw(minutes_to_time time_to_minutes unit_conversion);

__PACKAGE__->belongs_to(
  "normalized_distance",
  "Moove::Model::Result::DistanceNormalized",
  {id => "distance_id"},
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

sub has_map ($self) {
  return $self->activity_points->count > 0;
}

sub end_time ($self) {
  return $self->start_time + ($self->duration // $self->net_time);
}

sub recalculate_pace ($self) {
  my $u = $self->result_source->schema->resultset('UnitOfMeasure');

  my $t = $self->net_time // $self->duration;
  return unless (defined($t));
  my $hours = time_to_minutes($t) / 60;
  my $miles = unit_conversion(value => $self->distance->value, from => $self->distance->unit_of_measure);

  my $speed = $miles / $hours;
  my $pace  = minutes_to_time(unit_conversion(value => $speed, from => $u->mph, to => $u->per_mile));

  $self->update({pace => $pace});
}

sub recalculate_speed ($self) {
  my $u = $self->result_source->schema->resultset('UnitOfMeasure');

  my $t = $self->net_time // $self->duration;
  return unless (defined($t));
  my $hours = time_to_minutes($t) / 60;
  my $miles = unit_conversion(value => $self->distance->value, from => $self->distance->unit_of_measure);

  my $speed = $miles / $hours;
  $self->update({speed => $speed});
}

1;

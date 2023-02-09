#<<<
use utf8;
package Moove::Model::Result::Activity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::Activity

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

=head1 TABLE: C<Activity>

=cut

__PACKAGE__->table("Activity");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 activity_type_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 workout_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 group_num

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 set_num

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 activity_result_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 note

  data_type: 'text'
  default_value: ''''
  is_nullable: 0

=head2 whole_activity_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 external_data_source_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 external_identifier

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 visibility_type_id

  data_type: 'integer'
  default_value: 1
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 created_at

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: 'current_timestamp()'
  is_nullable: 0

=head2 updated_at

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "activity_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "workout_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "group_num",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "set_num",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "activity_result_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "note",
  { data_type => "text", default_value => "''", is_nullable => 0 },
  "whole_activity_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "external_data_source_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "external_identifier",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "visibility_type_id",
  {
    data_type => "integer",
    default_value => 1,
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "created_at",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "current_timestamp()",
    is_nullable => 0,
  },
  "updated_at",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
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
  { "foreign.whole_activity_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 activity_result

Type: belongs_to

Related object: L<Moove::Model::Result::ActivityResult>

=cut

__PACKAGE__->belongs_to(
  "activity_result",
  "Moove::Model::Result::ActivityResult",
  { id => "activity_result_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

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

=head2 external_data_source

Type: belongs_to

Related object: L<Moove::Model::Result::ExternalDataSource>

=cut

__PACKAGE__->belongs_to(
  "external_data_source",
  "Moove::Model::Result::ExternalDataSource",
  { id => "external_data_source_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 user_event_activities

Type: has_many

Related object: L<Moove::Model::Result::UserEventActivity>

=cut

__PACKAGE__->has_many(
  "user_event_activities",
  "Moove::Model::Result::UserEventActivity",
  { "foreign.activity_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_goal_fulfillment_activities

Type: has_many

Related object: L<Moove::Model::Result::UserGoalFulfillmentActivity>

=cut

__PACKAGE__->has_many(
  "user_goal_fulfillment_activities",
  "Moove::Model::Result::UserGoalFulfillmentActivity",
  { "foreign.activity_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 visibility_type

Type: belongs_to

Related object: L<Moove::Model::Result::VisibilityType>

=cut

__PACKAGE__->belongs_to(
  "visibility_type",
  "Moove::Model::Result::VisibilityType",
  { id => "visibility_type_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 whole_activity

Type: belongs_to

Related object: L<Moove::Model::Result::Activity>

=cut

__PACKAGE__->belongs_to(
  "whole_activity",
  "Moove::Model::Result::Activity",
  { id => "whole_activity_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 workout

Type: belongs_to

Related object: L<Moove::Model::Result::Workout>

=cut

__PACKAGE__->belongs_to(
  "workout",
  "Moove::Model::Result::Workout",
  { id => "workout_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user_goal_fulfillments

Type: many_to_many

Composing rels: L</user_goal_fulfillment_activities> -> user_goal_fulfillment

=cut

__PACKAGE__->many_to_many(
  "user_goal_fulfillments",
  "user_goal_fulfillment_activities",
  "user_goal_fulfillment",
);
#>>>
use v5.36;

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-09 12:32:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uAeO+EoBhRY6mjqkRNqs3w
use List::Util qw(max);

use Class::Method::Modifiers;

sub is_event_activity($self) {
  return $self->user_event_activities->count > 0;
}

sub user_event_activity($self) {
  return unless($self->is_event_activity);
  return $self->user_event_activities->first;
}

sub last_updated_at ($self) {
  return $self->updated_at // $self->created_at;
}

sub result ($self) {
  return $self->activity_result;
}

sub start_time ($self) {
  return $self->activity_result->start_time;
}

sub start_date ($self) {
  return undef unless(defined($self->activity_result));
  return undef unless(defined($self->activity_result->start_time));
  return $self->activity_result->start_time->truncate(to => 'day');
}

sub description ($self) {
  return sprintf('%s %s %s', $self->start_time->strftime('%F'), $self->distance->description, $self->activity_type->description);
}

around 'note' => sub ($orig, $self, @args) {
  my $v = $self->$orig(@args) // '';
  $v =~ s/\s*$//m;
  $v =~ s/^\s*//m;
  return $v;
};

sub is_outdoor_activity ($self) {
  return $self->activity_type->description ne 'Treadmill';
}

sub is_running_activity ($self) {
  return $self->activity_type->description eq 'Run' || $self->activity_type->description eq 'Treadmill';
}

sub is_cycling_activity ($self) {
  return $self->activity_type->description eq 'Ride';
}

sub end_time ($self) {
  if (my $ar = $self->activity_result) {
    return $ar->start_time + $self->total_time;
  }
  return undef;
}

sub total_time ($self) {
  if (my $ar = $self->activity_result) {
    return $ar->duration // $ar->net_time;
  }
  return undef;
}

sub first_activity_point ($self) {
  return $self->activity_result->activity_points->search(
    {},
    {
      order_by => {'-asc' => 'timestamp'}
    }
  )->first;
}

sub last_activity_point ($self) {
  return $self->activity_result->activity_points->search(
    {},
    {
      order_by => {'-desc' => 'timestamp'}
    }
  )->first;
}

sub sets ($self) {
  return $self->workout->activities->search(
    {
      activity_type_id => $self->activity_type_id,
      group_num        => $self->group_num,
    }
  )->all;
}

1;

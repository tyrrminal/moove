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

=head2 start_time

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

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
  "start_time",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
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

=head2 activity_sets

Type: has_many

Related object: L<Moove::Model::Result::ActivitySet>

=cut

__PACKAGE__->has_many(
  "activity_sets",
  "Moove::Model::Result::ActivitySet",
  { "foreign.activity_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-01-02 12:58:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xGwdSTkPmk2Ylzt5FcIjCw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
use List::Util qw(max);

use Moose;
use MooseX::NonMoose;

sub description {
  my $self = shift;

  return sprintf('%s %s %s', $self->start_time->strftime('%F'), $self->distance->description, $self->activity_type->description);
}

around 'note' => sub {
  my $orig = shift;
  my $self = shift;

  my $v = $self->$orig(@_) // '';
  $v =~ s/\s*$//m;
  $v =~ s/^\s*//m;
  return $v;
};

sub is_outdoor_activity {
  return shift->activity_type->description ne 'Treadmill';
}

sub is_running_activity {
  my $self = shift;
  return $self->activity_type->description eq 'Run' || $self->activity_type->description eq 'Treadmill';
}

sub is_cycling_activity {
  return shift->activity_type->description eq 'Ride';
}

sub end_time {
  my $self = shift;

  return $self->start_time unless (defined($self->result));
  return $self->start_time + ($self->result->gross_time // $self->result->net_time);
}

sub first_activity_point {
  my $self = shift;

  return $self->activity_points->search(
    {},
    {
      order_by => {'-asc' => 'timestamp'}
    }
  )->first;
}

sub last_activity_point {
  my $self = shift;

  return $self->activity_points->search(
    {},
    {
      order_by => {'-desc' => 'timestamp'}
    }
  )->first;
}

1;

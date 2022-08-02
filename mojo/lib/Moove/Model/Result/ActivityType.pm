#<<<
use utf8;
package Moove::Model::Result::ActivityType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::ActivityType

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

=head1 TABLE: C<ActivityType>

=cut

__PACKAGE__->table("ActivityType");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 base_activity_type_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 activity_context_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
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
  "base_activity_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "activity_context_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<base_activity_type_UNIQUE>

=over 4

=item * L</base_activity_type_id>

=item * L</activity_context_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "base_activity_type_UNIQUE",
  ["base_activity_type_id", "activity_context_id"],
);

=head1 RELATIONS

=head2 activities

Type: has_many

Related object: L<Moove::Model::Result::Activity>

=cut

__PACKAGE__->has_many(
  "activities",
  "Moove::Model::Result::Activity",
  { "foreign.activity_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 activity_context

Type: belongs_to

Related object: L<Moove::Model::Result::ActivityContext>

=cut

__PACKAGE__->belongs_to(
  "activity_context",
  "Moove::Model::Result::ActivityContext",
  { id => "activity_context_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 base_activity_type

Type: belongs_to

Related object: L<Moove::Model::Result::BaseActivityType>

=cut

__PACKAGE__->belongs_to(
  "base_activity_type",
  "Moove::Model::Result::BaseActivityType",
  { id => "base_activity_type_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event_types

Type: has_many

Related object: L<Moove::Model::Result::EventType>

=cut

__PACKAGE__->has_many(
  "event_types",
  "Moove::Model::Result::EventType",
  { "foreign.activity_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_nominal_activities

Type: has_many

Related object: L<Moove::Model::Result::UserNominalActivity>

=cut

__PACKAGE__->has_many(
  "user_nominal_activities",
  "Moove::Model::Result::UserNominalActivity",
  { "foreign.activity_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>
use v5.36;

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-09 12:32:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jv5xGLLZEwz9Dnvm7bJyzQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use DCS::Constants qw(:symbols);

sub description ($self) {
  return join($SPACE, $self->activity_context->description, $self->base_activity_type->description) if ($self->activity_context);
  return $self->base_activity_type->description;
}

sub valid_fields ($self) {
  my $b = $self->base_activity_type;
  my $c = $self->activity_context;

  my @f = qw(id start_time weight heart_rate temperature);
  push(@f, qw(repetitions))            if ($b->has_repeats);
  push(@f, qw(distance_id))            if ($b->has_distance);
  push(@f, qw(duration net_time))      if ($b->has_duration);
  push(@f, qw(pace))                   if ($b->has_pace);
  push(@f, qw(speed))                  if ($b->has_speed);
  push(@f, qw(map_visibility_type_id)) if ($c->has_map);
  return @f;
}

1;

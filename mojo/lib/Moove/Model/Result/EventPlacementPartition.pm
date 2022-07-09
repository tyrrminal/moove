#<<<
use utf8;
package Moove::Model::Result::EventPlacementPartition;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::EventPlacementPartition

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

=head1 TABLE: C<EventPlacementPartition>

=cut

__PACKAGE__->table("EventPlacementPartition");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 event_activity_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 division_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 gender_id

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
  "event_activity_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "division_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "gender_id",
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

=head1 RELATIONS

=head2 division

Type: belongs_to

Related object: L<Moove::Model::Result::Division>

=cut

__PACKAGE__->belongs_to(
  "division",
  "Moove::Model::Result::Division",
  { id => "division_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 event_activity

Type: belongs_to

Related object: L<Moove::Model::Result::EventActivity>

=cut

__PACKAGE__->belongs_to(
  "event_activity",
  "Moove::Model::Result::EventActivity",
  { id => "event_activity_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event_placements

Type: has_many

Related object: L<Moove::Model::Result::EventPlacement>

=cut

__PACKAGE__->has_many(
  "event_placements",
  "Moove::Model::Result::EventPlacement",
  { "foreign.event_placement_partition_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gender

Type: belongs_to

Related object: L<Moove::Model::Result::Gender>

=cut

__PACKAGE__->belongs_to(
  "gender",
  "Moove::Model::Result::Gender",
  { id => "gender_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);
#>>>
use v5.36;

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-09 12:32:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FedjgM+ToFZeCFjJ4CJaWQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
sub description ($self) {
  return $self->gender->description   if (defined($self->gender));
  return $self->division->description if (defined($self->division));
  return 'Overall';
}

sub partition_type ($self) {
  return 'gender'   if (defined($self->gender));
  return 'division' if (defined($self->division));
  return undef;
}

sub update_count ($self) {
  $self->update({count => $self->event_results->count});
}

sub participants ($self) {
  my $rs = $self->result_source->schema->resultset('EventParticipant')->for_event_activity($self->event_activity);
  if (defined($self->gender)) {
    $rs = $rs->of_gender($self->gender);
  } elsif (defined($self->division)) {
    $rs = $rs->in_division($self->division);
  }
  return $rs;
}

1;

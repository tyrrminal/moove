#<<<
use utf8;
package Moove::Model::Result::EventResultGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::EventResultGroup

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

=head1 TABLE: C<event_result_group>

=cut

__PACKAGE__->table("event_result_group");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 event_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 gender_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 division_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 count

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "event_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "gender_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "division_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "count",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<uniq_event_gender_division_idx1>

=over 4

=item * L</event_id>

=item * L</gender_id>

=item * L</division_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "uniq_event_gender_division_idx1",
  ["event_id", "gender_id", "division_id"],
);

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

=head2 event

Type: belongs_to

Related object: L<Moove::Model::Result::Event>

=cut

__PACKAGE__->belongs_to(
  "event",
  "Moove::Model::Result::Event",
  { id => "event_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event_results

Type: has_many

Related object: L<Moove::Model::Result::EventResult>

=cut

__PACKAGE__->has_many(
  "event_results",
  "Moove::Model::Result::EventResult",
  { "foreign.event_result_group_id" => "self.id" },
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

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-02 13:17:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:L38xJzhoLulMVoEmr1Y9+w
use Modern::Perl;

# You can replace this text with custom code or comments, and it will be preserved on regeneration
sub description {
  my $self = shift;

  my $g;
  if (defined($self->gender)) {
    $g = $self->gender->description;
  } elsif (defined($self->division)) {
    $g = $self->division->name;
  } else {
    $g = 'Overall';
  }
  return join('/', $self->event->description, $g);
}

sub update_count {
  my $self = shift;

  $self->update({count => $self->event_results->count});
}

1;

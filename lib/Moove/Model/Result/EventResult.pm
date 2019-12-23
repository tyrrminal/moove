#<<<
use utf8;
package Moove::Model::Result::EventResult;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::EventResult

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

=head1 TABLE: C<event_result>

=cut

__PACKAGE__->table("event_result");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 result_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 place

  data_type: 'integer'
  is_nullable: 0

=head2 event_result_group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "result_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "place",
  { data_type => "integer", is_nullable => 0 },
  "event_result_group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 event_result_group

Type: belongs_to

Related object: L<Moove::Model::Result::EventResultGroup>

=cut

__PACKAGE__->belongs_to(
  "event_result_group",
  "Moove::Model::Result::EventResultGroup",
  { id => "event_result_group_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 result

Type: belongs_to

Related object: L<Moove::Model::Result::Result>

=cut

__PACKAGE__->belongs_to(
  "result",
  "Moove::Model::Result::Result",
  { id => "result_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-02 13:17:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NGoyhkoicWUVyINeBqYE1w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
sub to_hash {
  my $self=shift;

  my $place = $self->place;
  my $finishers =$self->event_result_group->count; 
  my $pct = 100*$place/$finishers;

  my $er = {
    place => $place,
    finishers => $finishers,
    percentile => $pct
  };

  $er->{gender} = $self->event_result_group->gender->description if(defined($self->event_result_group->gender));
  $er->{division} = $self->event_result_group->division->name if(defined($self->event_result_group->division));

  return $er;
}

1;

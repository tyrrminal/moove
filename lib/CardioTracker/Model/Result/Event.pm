use utf8;
package CardioTracker::Model::Result::Event;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::Event

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

=head1 TABLE: C<event>

=cut

__PACKAGE__->table("event");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 scheduled_start

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 entrants

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 event_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 distance_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 location_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "scheduled_start",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "entrants",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "event_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "distance_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "location_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
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

Related object: L<CardioTracker::Model::Result::Activity>

=cut

__PACKAGE__->has_many(
  "activities",
  "CardioTracker::Model::Result::Activity",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 distance

Type: belongs_to

Related object: L<CardioTracker::Model::Result::Distance>

=cut

__PACKAGE__->belongs_to(
  "distance",
  "CardioTracker::Model::Result::Distance",
  { id => "distance_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event_references

Type: has_many

Related object: L<CardioTracker::Model::Result::EventReference>

=cut

__PACKAGE__->has_many(
  "event_references",
  "CardioTracker::Model::Result::EventReference",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_registrations

Type: has_many

Related object: L<CardioTracker::Model::Result::EventRegistration>

=cut

__PACKAGE__->has_many(
  "event_registrations",
  "CardioTracker::Model::Result::EventRegistration",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_result_groups

Type: has_many

Related object: L<CardioTracker::Model::Result::EventResultGroup>

=cut

__PACKAGE__->has_many(
  "event_result_groups",
  "CardioTracker::Model::Result::EventResultGroup",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_type

Type: belongs_to

Related object: L<CardioTracker::Model::Result::EventType>

=cut

__PACKAGE__->belongs_to(
  "event_type",
  "CardioTracker::Model::Result::EventType",
  { id => "event_type_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 location

Type: belongs_to

Related object: L<CardioTracker::Model::Result::Location>

=cut

__PACKAGE__->belongs_to(
  "location",
  "CardioTracker::Model::Result::Location",
  { id => "location_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-11-19 17:38:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hndv1Y0Y+utjUEHkgTCcsQ

use DCS::Constants qw(:boolean :existence :symbols);

# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub create_gender_result_group {
  my $self=shift;
  my ($gender) = @_;
  my $schema = $self->result_source->schema;

  my $rs_r = $schema->resultset('Result')->search({
    'participants.gender_id' => $gender->id,
    'events.id' => $self->id
  },{
    join => [
      'participants',
      { activity => 'events' }
    ],
    order_by => { -asc => 'net_time' }
  });

  my $group = $schema->resultset('EventResultGroup')->create({
    event => $self,
    gender => $gender,
    division_id => $NULL,
    count => $rs_r->count
  });

  my $i=1;
  while (my $r = $rs_r->next) {
    $schema->resultset('EventResult')->create({
      result => $r,
      place => $i++,
      event_result_group => $group
    });
  }
}

sub description {
  my $self=shift;
  my $year = $self->scheduled_start->year;
  my $name = $self->name;
  unless($name =~ /$year/) {
    $name = join($SPACE, $year, $name)
  }
  return $name;
}

1;

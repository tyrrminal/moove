#<<<
use utf8;
package Moove::Model::Result::EventActivity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::EventActivity

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

=head1 TABLE: C<EventActivity>

=cut

__PACKAGE__->table("EventActivity");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 scheduled_start

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 entrants

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 event_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 distance_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 event_type_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 external_identifier

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "scheduled_start",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "entrants",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "event_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "distance_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "event_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "external_identifier",
  { data_type => "varchar", is_nullable => 1, size => 45 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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

=head2 event_placement_partitions

Type: has_many

Related object: L<Moove::Model::Result::EventPlacementPartition>

=cut

__PACKAGE__->has_many(
  "event_placement_partitions",
  "Moove::Model::Result::EventPlacementPartition",
  { "foreign.event_activity_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_registrations

Type: has_many

Related object: L<Moove::Model::Result::EventRegistration>

=cut

__PACKAGE__->has_many(
  "event_registrations",
  "Moove::Model::Result::EventRegistration",
  { "foreign.event_activity_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_type

Type: belongs_to

Related object: L<Moove::Model::Result::EventType>

=cut

__PACKAGE__->belongs_to(
  "event_type",
  "Moove::Model::Result::EventType",
  { id => "event_type_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
#>>>
use v5.36;

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-07-09 12:32:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HhVDw3uoJNS9EbA1NywLog


# You can replace this text with custom code or comments, and it will be preserved on regeneration
use Module::Util qw(module_path);

use DCS::Constants qw(:symbols);

sub description ($self) {
  return join($SPACE, grep {defined} ($self->event->name, $self->name || undef));
}

sub url ($self) {
  my @urls = ($self->event->url);
  if (my $edc = $self->event->external_data_source) {
    require(module_path($edc->import_class));
    my $importer = $edc->import_class->new(event_id => $self->event->external_identifier, race_id => $self->external_identifier);
    push(@urls, $importer->url);
  }
  @urls = grep {defined} @urls;
  return $urls[0];
}

1;

#<<<
use utf8;
package Moove::Model::Result::Event;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::Event

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

=head1 TABLE: C<Event>

=cut

__PACKAGE__->table("Event");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 year

  data_type: 'smallint'
  is_nullable: 0

=head2 url

  data_type: 'text'
  is_nullable: 1

=head2 address_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 event_group_id

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
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "year",
  { data_type => "smallint", is_nullable => 0 },
  "url",
  { data_type => "text", is_nullable => 1 },
  "address_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "event_group_id",
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
  { data_type => "varchar", is_nullable => 1, size => 45 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 address

Type: belongs_to

Related object: L<Moove::Model::Result::Address>

=cut

__PACKAGE__->belongs_to(
  "address",
  "Moove::Model::Result::Address",
  { id => "address_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event_activities

Type: has_many

Related object: L<Moove::Model::Result::EventActivity>

=cut

__PACKAGE__->has_many(
  "event_activities",
  "Moove::Model::Result::EventActivity",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_group

Type: belongs_to

Related object: L<Moove::Model::Result::EventGroup>

=cut

__PACKAGE__->belongs_to(
  "event_group",
  "Moove::Model::Result::EventGroup",
  { id => "event_group_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 event_series_events

Type: has_many

Related object: L<Moove::Model::Result::EventSeriesEvent>

=cut

__PACKAGE__->has_many(
  "event_series_events",
  "Moove::Model::Result::EventSeriesEvent",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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

=head2 event_series

Type: many_to_many

Composing rels: L</event_series_events> -> event_series

=cut

__PACKAGE__->many_to_many("event_series", "event_series_events", "event_series");
#>>>
use v5.36;

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-08-02 10:06:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dxZzTINoF7nRQPgCpt+KEw

use DCS::DateTime::Extras;
use DCS::Constants qw(:symbols);

sub address ($self) {
  return $self->event_group->address;
}

sub description ($self) {
  my $year = $self->scheduled_start->year;
  my $name = $self->event_group->name;
  if (my $sub_name = $self->name) {
    $name = join($SPACE, $name, $sub_name);
  }
  unless ($name =~ /$year/) {
    $name = join($SPACE, $year, $name);
  }
  return $name;
}

sub countdown ($self) {
  my $now   = DateTime->now(time_zone => 'local');
  my $start = $self->scheduled_start;

  my $days = $now->delta_days($start)->in_units('days');
  return {
    days   => $days,
    weeks  => sprintf("%.01f", $days / 7),
    months => sprintf("%.01f", $start->yearfrac($now) * 12)
  };
}

1;

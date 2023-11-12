#<<<
use utf8;
package Moove::Model::Result::EventGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::EventGroup

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

=head1 TABLE: C<EventGroup>

=cut

__PACKAGE__->table("EventGroup");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url

  data_type: 'text'
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 is_parent

  data_type: 'enum'
  default_value: 'Y'
  extra: {list => ["Y","N"]}
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
  "url",
  { data_type => "text", is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "is_parent",
  {
    data_type => "enum",
    default_value => "Y",
    extra => { list => ["Y", "N"] },
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

=head2 event_series_events

Type: has_many

Related object: L<Moove::Model::Result::EventSeriesEvent>

=cut

__PACKAGE__->has_many(
  "event_series_events",
  "Moove::Model::Result::EventSeriesEvent",
  { "foreign.event_series_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events_2s

Type: has_many

Related object: L<Moove::Model::Result::Event>

=cut

__PACKAGE__->has_many(
  "events_2s",
  "Moove::Model::Result::Event",
  { "foreign.event_group_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events

Type: many_to_many

Composing rels: L</event_series_events> -> event

=cut

__PACKAGE__->many_to_many("events", "event_series_events", "event");
#>>>
use v5.38;

# Created by DBIx::Class::Schema::Loader v0.07051 @ 2023-11-09 16:41:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RqUtuBTHw7FIc1b/+MQ0Xg

use Class::Method::Modifiers;

around [qw(is_parent)] => sub ($orig, $self, $value = undef) {
  if (defined($value)) {
    $value = $self->$orig($value ? 'Y' : 'N');
  } else {
    $value = $self->$orig();
  }
  return $value eq 'Y';
};

sub description ($self) {
  return $self->name
}

sub user_event_activities ($self) {
  my $rs;
  if (defined($self->year)) {
    $rs = $self->event_series_events->related_resultset('event');
  } else {
    $rs = $self->events_2s;
  }

  return $rs->related_resultset('event_activities')->related_resultset('event_registrations')
    ->related_resultset('user_event_activities');
}

1;

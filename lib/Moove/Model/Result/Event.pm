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

=head1 TABLE: C<event>

=cut

__PACKAGE__->table("event");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 event_group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

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

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "event_group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
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
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 distance

Type: belongs_to

Related object: L<Moove::Model::Result::Distance>

=cut

__PACKAGE__->belongs_to(
  "distance",
  "Moove::Model::Result::Distance",
  { id => "distance_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event_group

Type: belongs_to

Related object: L<Moove::Model::Result::EventGroup>

=cut

__PACKAGE__->belongs_to(
  "event_group",
  "Moove::Model::Result::EventGroup",
  { id => "event_group_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event_references

Type: has_many

Related object: L<Moove::Model::Result::EventReference>

=cut

__PACKAGE__->has_many(
  "event_references",
  "Moove::Model::Result::EventReference",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_registrations

Type: has_many

Related object: L<Moove::Model::Result::EventRegistration>

=cut

__PACKAGE__->has_many(
  "event_registrations",
  "Moove::Model::Result::EventRegistration",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_result_groups

Type: has_many

Related object: L<Moove::Model::Result::EventResultGroup>

=cut

__PACKAGE__->has_many(
  "event_result_groups",
  "Moove::Model::Result::EventResultGroup",
  { "foreign.event_id" => "self.id" },
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

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-02 13:17:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tVskdgFWW4HQUZGwxH/OvQ

use Moove::Import::Event::RaceWire;
use Moove::Import::Event::IResultsLive;
use Moove::Import::Event::MTEC;
use Moove::Import::Event::MillenniumRunning;

use DCS::DateTime::Extras;
use DCS::Constants qw(:boolean :existence :symbols);

# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub address {
  my $self = shift;
  return $self->event_group->address;
}

sub update_missing_group_counts {
  my $self = shift;

  my $rs = $self->result_source->schema->resultset('EventResultGroup')->for_event($self)->missing_count;
  while (my $g = $rs->next) {
    $g->update_count;
  }
}

sub add_missing_gender_groups {
  my $self = shift;

  foreach my $g ($self->result_source->schema->resultset('Gender')->all) {
    $self->create_gender_result_group($g)
      unless ($self->event_result_groups->search({gender_id => $g->id, division_id => $NULL})->count);
  }
}

sub update_missing_result_paces {
  my $self = shift;

  my $rs = $self->result_source->schema->resultset('Result')->for_event($self)->needs_pace;
  while (my $r = $rs->next) {
    $r->update_pace;
  }
}

sub create_gender_result_group {
  my $self     = shift;
  my ($gender) = @_;
  my $schema   = $self->result_source->schema;

  my $rs_r = $schema->resultset('Result')->search(
    {
      'participants.gender_id' => $gender->id,
      'event.id'               => $self->id
    }, {
      join     => ['participants', {activities => 'event'}],
      order_by => {-asc            => 'net_time'}
    }
  );

  my $group = $schema->resultset('EventResultGroup')->create(
    {
      event       => $self,
      gender      => $gender,
      division_id => $NULL,
      count       => $rs_r->count
    }
  );

  my $i = 1;
  while (my $r = $rs_r->next) {
    $schema->resultset('EventResult')->create(
      {
        result             => $r,
        place              => $i++,
        event_result_group => $group
      }
    );
  }
}

sub description {
  my $self = shift;
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

sub countdown {
  my $self  = shift;
  my $now   = DateTime->now(time_zone => 'local');
  my $start = $self->scheduled_start;

  my $days = $now->delta_days($start)->in_units('days');
  return {
    days   => $days,
    weeks  => sprintf("%.01f", $days / 7),
    months => sprintf("%.01f", $start->yearfrac($now) * 12)
  };
}

sub router_link {
  my $self = shift;

  return {
    route_name => 'event',
    params     => {id => $self->id},
    text       => $self->description
  };
}

sub event_url {
  my $self = shift;

  my $url = $self->event_group->url;
  return $url if (defined($url));

  if (my $seq = $self->event_group->event_sequence) {
    return $seq->url;
  }
  return undef;
}

sub results_url {
  my $self = shift;

  my @urls;
  foreach ($self->event_references) {
    my $ert = $_->event_reference_type;
    my $importer = sprintf('Moove::Import::Event::%s', $ert->description)->new(event_id => $_->ref_num, race_id => $_->sub_ref_num);
    push(@urls, $importer->url);
  }

  return $urls[0];
}

1;

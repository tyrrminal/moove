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

=head2 event_group

Type: belongs_to

Related object: L<CardioTracker::Model::Result::EventGroup>

=cut

__PACKAGE__->belongs_to(
  "event_group",
  "CardioTracker::Model::Result::EventGroup",
  { id => "event_group_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-07-24 10:27:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sVZtRZ8/Ef2+jTbFvB6Ocw

use CardioTracker::Import::Event::RaceWire;
use CardioTracker::Import::Event::IResultsLive;
use CardioTracker::Import::Event::MTEC;
use CardioTracker::Import::Event::MillenniumRunning;

use DCS::DateTime::Extras;
use DCS::Constants qw(:boolean :existence :symbols);

# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub address {
  my $self = shift;
  return $self->event_group->address;
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
    my $importer =
      sprintf('CardioTracker::Import::Event::%s', $ert->description)->new(event_id => $_->ref_num, race_id => $_->sub_ref_num);
    push(@urls, $importer->url);
  }

  return $urls[0];
}

sub to_hash {
  my $self = shift;
  my %cd = ($self->scheduled_start > DateTime->now(time_zone => 'local')) ? (countdown => $self->countdown) : ();

  my $e = {
    id                => $self->id,
    name              => $self->event_group->name,
    url               => $self->event_url,
    results_url       => $self->results_url,
    scheduled_start   => $self->scheduled_start->iso8601,
    entrants          => $self->entrants,
    event_type        => $self->event_type->to_hash,
    distance          => $self->distance->to_hash,
    event_sequence_id => $self->event_group->event_sequence_id,
    %cd
  };
  $e->{address} = $self->address->to_hash unless ($self->address->is_empty);

  return $e;
}

1;

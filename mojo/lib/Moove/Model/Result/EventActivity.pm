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

=head2 import_parameters

  data_type: 'longtext'
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
  "import_parameters",
  { data_type => "longtext", is_nullable => 1 },
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
use v5.38;

# Created by DBIx::Class::Schema::Loader v0.07051 @ 2023-08-14 09:22:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BfaWIUCOFXDM6ZUNxT1YJQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
use Mojo::Util   qw(class_to_path);
use Scalar::Util qw(looks_like_number);
use Mojo::JSON   qw(decode_json);

use Moove::Util::Extraction qw(selective_field_extract);

use DCS::Constants qw(:symbols);

sub description ($self) {
  return join($SPACE, grep {defined} ($self->event->name, $self->name || undef));
}

sub url ($self) {
  my @urls = ($self->event->url);
  if (my $edc = $self->event->external_data_source) {
    require(class_to_path($edc->import_class));
    if (defined($edc->import_class->import_param_schemas)) {
      my $importer = $edc->import_class->new(import_params => $self->all_import_params);
      unshift(@urls, $importer->url);
    }
  }
  @urls = grep {defined} @urls;
  return $urls[0];
}

sub import_validation_errors ($self) {
  if (my $edc = $self->event->external_data_source) {
    my @errors;
    my $class = $edc->import_class;
    require(class_to_path($class));
    my $schemas = $class->import_param_schemas;

    push(@errors, $schemas->{event}->validate($self->event->import_params));
    push(@errors, $schemas->{eventactivity}->validate($self->import_params));
    return @errors;
  }
  return ('No import data source configured');
}

sub is_importable ($self) {
  my @errors = $self->import_validation_errors;
  return @errors < 1;
}

sub has_results ($self) {
  return $self->event_registrations->related_resultset('event_participants')->count > 0;
}

sub delete_results ($self) {
  $self->event_placement_partitions->related_resultset('event_placements')->delete();
  $self->event_placement_partitions->delete();
  $self->event_registrations->related_resultset('event_participants')->delete();
  $self->event_registrations->without_user_activity->delete();
}

sub add_participant ($self, $p) {
  my $schema = $self->result_source->schema;

  my $reg_no = $p->{bib_no};
  if ($reg_no =~ /\W/) {
    say STDERR "Truncating $reg_no";
    $reg_no =~ s/\W//g;
  }

  my $reg =
    $schema->resultset('EventRegistration')->find_or_create({event_activity_id => $self->id, registration_number => $p->{bib_no}});
  my $person =
    $schema->resultset('Person')->get_person(map {$_ => $p->{$_}} qw(first_name last_name gender age));
  my $result = $schema->resultset('ActivityResult')->create(
    selective_field_extract(
      {
        start_time  => $self->scheduled_start,
        distance_id => $self->distance->id,
        duration    => $p->{gross_time},
        net_time    => $p->{net_time},
        pace        => $p->{pace},
        speed       => $p->{speed},
      },
      [$self->event_type->activity_type->valid_fields]
    )
  );

  my $address = $schema->resultset('Address')->get_address(city => $p->{city}, state => $p->{state}, country => $p->{country});
  my $gender  = $schema->resultset('Gender')->find({abbreviation => $p->{gender}});
  my $division =
    $p->{division} ? $schema->resultset('Division')->find_or_create({name => $p->{division}}) : undef;
  $p->{age} = undef unless (looks_like_number($p->{age}));

  my $participant = $schema->resultset('EventParticipant')->create(
    {
      event_registration => {
        event_activity_id   => $self->id,
        registration_number => $reg_no,
      },
      event_result => $result,
      age          => $p->{age},
      person_id    => $person->id,
      address_id   => $address->id,
      gender_id    => defined($gender)   ? $gender->id   : undef,
      division_id  => defined($division) ? $division->id : undef,
    }
  );

  my %partitions = $schema->resultset('EventPlacementPartition')->get_partitions($self, $gender, $division);
  $participant->add_placement($partitions{overall},  $p->{overall_place});
  $participant->add_placement($partitions{gender},   $p->{gender_place}) if ($p->{gender_place});
  $participant->add_placement($partitions{division}, $p->{div_place})    if ($p->{div_place});

  return $participant;
}

sub update_missing_result_paces ($self) {
  return unless ($self->event_type->activity_type->base_activity_type->has_pace);
  my $rs =
    $self->event_registrations->related_resultset('event_participants')->related_resultset('event_result')->search({pace => undef});
  while (my $r = $rs->next) {
    $r->recalculate_pace;
  }
}

sub add_placements_for_gender ($self, $gender) {
  my $partition = $self->event_placement_partitions->search({division_id => undef, gender_id => $gender->id})->first;
  return if ($partition->event_placements->count > 0);
  my $participants = $self->event_placement_partitions->overall->event_placements->ordered->related_resultset('event_participant')
    ->search({gender_id => $gender->id});
  my $n = 1;
  while (my $participant = $participants->next) {
    $partition->add_to_event_placements(
      {
        place                        => $n++,
        event_participant_id         => $participant->id,
        event_placement_partition_id => $partition->id,
      }
    );
  }
}

sub import_params ($self) {
  return decode_json($self->import_parameters) if ($self->import_parameters);
  return {};
}

sub all_import_params ($self) {
  return {$self->event->import_params->%*, $self->import_params->%*};
}

sub qualified_external_identifier ($self) {
  return join($UNDERSCORE, grep {defined} ($self->import_params->{event_id}, $self->import_params->{race_id}));
}

1;

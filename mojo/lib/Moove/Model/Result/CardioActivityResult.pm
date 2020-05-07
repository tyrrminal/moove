#<<<
use utf8;
package Moove::Model::Result::CardioActivityResult;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::CardioActivityResult

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

=head1 TABLE: C<CardioActivityResult>

=cut

__PACKAGE__->table("CardioActivityResult");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 gross_time

  data_type: 'time'
  is_nullable: 1

=head2 net_time

  data_type: 'time'
  is_nullable: 0

=head2 pace

  data_type: 'time'
  is_nullable: 1

=head2 speed

  data_type: 'decimal'
  is_nullable: 1
  size: [7,3]

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "gross_time",
  { data_type => "time", is_nullable => 1 },
  "net_time",
  { data_type => "time", is_nullable => 0 },
  "pace",
  { data_type => "time", is_nullable => 1 },
  "speed",
  { data_type => "decimal", is_nullable => 1, size => [7, 3] },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 cardio_activity_sets

Type: has_many

Related object: L<Moove::Model::Result::CardioActivitySet>

=cut

__PACKAGE__->has_many(
  "cardio_activity_sets",
  "Moove::Model::Result::CardioActivitySet",
  { "foreign.cardio_activity_result_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 cardio_event_participants

Type: has_many

Related object: L<Moove::Model::Result::CardioEventParticipant>

=cut

__PACKAGE__->has_many(
  "cardio_event_participants",
  "Moove::Model::Result::CardioEventParticipant",
  { "foreign.cardio_activity_result_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-05-07 12:23:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xF8hHYIrp+s82tdziBroig


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use Moose;
use MooseX::NonMoose;

use DateTime::Format::Duration;

# Pace is always minutes (net) per mile
sub update_pace {
  my $self = shift;
  $self->update({pace => _calculate_pace($self->net_time, $self->activities->first->distance)});
}

around 'speed' => sub {
  my $orig = shift;
  my $self = shift;

  return $self->result_source->schema->resultset('Distance')->new_result(
    {
      value => $self->$orig,
      uom   => $self->result_source->schema->resultset('UnitOfMeasure')->find({abbreviation => 'mph'})->id
    }
  );
};

sub _calculate_pace {
  my ($time, $distance) = @_;

  my ($min, $sec) = $time->in_units(qw(minutes seconds));
  $min += $sec / 60;

  my $miles = $distance->value * $distance->uom->conversion_factor;

  return _minutes_to_time_str($min / $miles);
}

sub _minutes_to_time_str {
  my ($t) = @_;
  my $dec = $t - int($t);

  my ($min, $sec) = (int($t), $dec * 60);
  if ($sec > 59.94) {
    $min++;
    $sec = 0;
  }

  return sprintf("00:%02d:%04.1f", $min, $sec);
}

sub _format_time {
  my $t = shift;
  return undef unless ($t);

  my $d = DateTime::Format::Duration->new(pattern => '%H:%M:%S', normalise => 1);
  return $d->format_duration($t);
}

sub gross_time_formatted {
  my $self = shift;

  return _format_time($self->gross_time);
}

sub net_time_formatted {
  my $self = shift;

  return _format_time($self->net_time);
}

sub pace_formatted {
  my $self = shift;

  return _format_time($self->pace);
}

1;


1;

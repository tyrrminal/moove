use utf8;
package CardioTracker::Model::Result::Result;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::Result

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

=head1 TABLE: C<result>

=cut

__PACKAGE__->table("result");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
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

=head2 heart_rate

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "gross_time",
  { data_type => "time", is_nullable => 1 },
  "net_time",
  { data_type => "time", is_nullable => 0 },
  "pace",
  { data_type => "time", is_nullable => 1 },
  "heart_rate",
  { data_type => "integer", is_nullable => 1 },
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
  { "foreign.result_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_results

Type: has_many

Related object: L<CardioTracker::Model::Result::EventResult>

=cut

__PACKAGE__->has_many(
  "event_results",
  "CardioTracker::Model::Result::EventResult",
  { "foreign.result_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 participants

Type: has_many

Related object: L<CardioTracker::Model::Result::Participant>

=cut

__PACKAGE__->has_many(
  "participants",
  "CardioTracker::Model::Result::Participant",
  { "foreign.result_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-07-11 22:42:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6ezHL09ftRs4VX9rLvrNpg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
use DateTime::Format::Duration;

# Pace is always minutes (net) per mile
sub update_pace {
  my $self = shift;
  $self->update({pace => _calculate_pace($self->net_time, $self->activities->first->distance)});
}

sub speed {
  my $self = shift;

  my $v;
  my $d = $self->activities->first->distance;
  my $miles = $self->result_source->schema->resultset('UnitOfMeasure')->find({abbreviation => 'mi'});
  if ($d->uom->id == $miles->id) {
    $v = $d->value;
  } elsif ($miles->conversion_factor == 1) {
    $v = $d->normalized_value;
  } else {
    $v = $d->normalized_value / $miles->conversion_factor;
  }
  my $mph = $self->result_source->schema->resultset('UnitOfMeasure')->find({abbreviation => 'mph'});

  my $t = $self->net_time;
  my $hrs = $t->hours + ($t->minutes / 60) + ($t->seconds / (60 * 60));

  return 0 unless ($hrs);
  return {
    value => $v/$hrs,
    units => $mph
  };
}

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

  my ($min,$sec) = (int($t), $dec * 60);
  if($sec > 59.94) {
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

sub to_hash {
  my $self = shift;
  my $norm = $self->result_source->schema->resultset('UnitOfMeasure')->normalization_unit('speed');

  return {
    id         => $self->id,
    gross_time => $self->gross_time_formatted,
    net_time   => $self->net_time_formatted,
    pace       => $self->pace_formatted,
    speed      => {
      quantity => {
        value => $self->speed->{value},
        units => $self->speed->{units}->to_hash
      },
      normalized_quantity => {
        value => $self->speed->{value} * $norm->conversion_factor,
        units => $norm->to_hash
      }
    },
    heart_rate => $self->heart_rate
  };
}

1;

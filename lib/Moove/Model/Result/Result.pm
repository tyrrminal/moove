#<<<
use utf8;
package Moove::Model::Result::Result;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::Result

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

=head2 speed

  data_type: 'decimal'
  is_nullable: 1
  size: [7,3]

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
  "speed",
  { data_type => "decimal", is_nullable => 1, size => [7, 3] },
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

Related object: L<Moove::Model::Result::Activity>

=cut

__PACKAGE__->has_many(
  "activities",
  "Moove::Model::Result::Activity",
  { "foreign.result_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_results

Type: has_many

Related object: L<Moove::Model::Result::EventResult>

=cut

__PACKAGE__->has_many(
  "event_results",
  "Moove::Model::Result::EventResult",
  { "foreign.result_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 participants

Type: has_many

Related object: L<Moove::Model::Result::Participant>

=cut

__PACKAGE__->has_many(
  "participants",
  "Moove::Model::Result::Participant",
  { "foreign.result_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-02 13:17:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1vt9LFGieVprtdZ19hDAcQ


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

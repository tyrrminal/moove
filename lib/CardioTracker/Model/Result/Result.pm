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

=head2 activity_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 start_time

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 gross_time

  data_type: 'time'
  is_nullable: 1

=head2 net_time

  data_type: 'time'
  is_nullable: 0

=head2 pace

  data_type: 'time'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "activity_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "start_time",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "gross_time",
  { data_type => "time", is_nullable => 1 },
  "net_time",
  { data_type => "time", is_nullable => 0 },
  "pace",
  { data_type => "time", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 activity

Type: belongs_to

Related object: L<CardioTracker::Model::Result::Activity>

=cut

__PACKAGE__->belongs_to(
  "activity",
  "CardioTracker::Model::Result::Activity",
  { id => "activity_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-11-15 18:33:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bZZWzQB30HDz6auZQ/j9CA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

# Pace is always minutes (net) per mile
sub update_pace {
  my $self=shift;

  my ($min,$sec) = $self->net_time->in_units(qw(minutes seconds));
  $min += $sec/60;

  my $d = $self->activity->distance;
  my $miles = $d->value * $d->uom->conversion_factor;

  $self->update({pace => _minutes_to_time_str($min/$miles)});
}

sub _minutes_to_time_str {
  my ($t) = @_;
  my $dec = $t - int($t);
  return sprintf("00:%02d:%04.1f", int($t), $dec*60);
}

1;

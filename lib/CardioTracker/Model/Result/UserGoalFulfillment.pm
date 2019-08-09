#<<<
use utf8;
package CardioTracker::Model::Result::UserGoalFulfillment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::UserGoalFulfillment

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

=head1 TABLE: C<user_goal_fulfillment>

=cut

__PACKAGE__->table("user_goal_fulfillment");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_goal_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 is_current

  data_type: 'enum'
  default_value: 'Y'
  extra: {list => ["Y","N"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_goal_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "is_current",
  {
    data_type => "enum",
    default_value => "Y",
    extra => { list => ["Y", "N"] },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 user_goal

Type: belongs_to

Related object: L<CardioTracker::Model::Result::UserGoal>

=cut

__PACKAGE__->belongs_to(
  "user_goal",
  "CardioTracker::Model::Result::UserGoal",
  { id => "user_goal_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user_goal_fulfillment_activities

Type: has_many

Related object: L<CardioTracker::Model::Result::UserGoalFulfillmentActivity>

=cut

__PACKAGE__->has_many(
  "user_goal_fulfillment_activities",
  "CardioTracker::Model::Result::UserGoalFulfillmentActivity",
  { "foreign.user_goal_fulfillment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 activities

Type: many_to_many

Composing rels: L</user_goal_fulfillment_activities> -> activity

=cut

__PACKAGE__->many_to_many("activities", "user_goal_fulfillment_activities", "activity");
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-06 15:42:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xfa7IZQYor7FUfpHp6w33A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
use DCS::DateTime::Extras;
use List::Util qw(sum reduce);
use InclusionCallback;

use DCS::Constants qw(:boolean);

sub get_goal_value {
  my $self = shift;
  unless (exists($self->{_goal_value})) {    # goal_value is computationally intensive, so we'll cache the result
    my $d                    = $self->user_goal->goal->dimension->description;
    my %dimension_lookup_map = (
      time     => sub {shift->result->net_time},
      pace     => sub {shift->result->pace},
      distance => sub {shift->distance},
      speed    => sub {shift->result->speed}
    );

    my %aggregation_lookup_map = (
      speed => sub {
        my @v      = map {$_->{value}} @_;
        my $v      = sum(@v) / @v;
        my $schema = $self->result_source->schema;
        return {
          value => $v,
          units => $schema->resultset('UnitOfMeasure')->normalization_unit('speed')
        };
      },
      time => sub {
        reduce {$a + $b} @_;
      },
      distance => sub {
        my $v = reduce {$a + $b} map {$_->normalized_value} @_;
        my $schema = $self->result_source->schema;
        return $schema->resultset('Distance')->new_result(
          {
            value => $v,
            uom   => $schema->resultset('UnitOfMeasure')->normalization_unit('distance')
          }
        );
      }
    );

    my $act_rs = $self->user_goal_fulfillment_activities;
    my $lu     = $dimension_lookup_map{$d};
    if (defined($self->user_goal->goal->goal_span)) {
      my @v = map {$lu->($_->activity)} $act_rs->all;
      $self->{_goal_value} = $aggregation_lookup_map{$d}->(@v);
    } else {
      $self->{_goal_value} = $lu->($act_rs->first->activity);
    }
  }
  return $self->{_goal_value};
}

sub get_goal_description {
  my $self               = shift;
  my $tf                 = DateTime::Format::Duration->new(pattern => '%T', normalize => 1);
  my $pf                 = DateTime::Format::Duration->new(pattern => '%T /mi', normalize => 1);
  my %dimension_desc_map = (
    time     => sub {$tf->format_duration(shift)},
    pace     => sub {$pf->format_duration(shift)},
    distance => sub {shift->description},
    speed    => sub {shift->description}
  );

  my $desc = $dimension_desc_map{$self->user_goal->goal->dimension->description};
  return $desc->($self->get_goal_value);
}

sub to_hash {
  my $self = shift;
  my $cb   = InclusionCallback->new(@_);

  my $r = {
    is_current  => $self->is_current eq 'Y',
    date        => $self->date->iso8601,
    description => $self->get_goal_description,
    value       => $self->get_goal_value->can('to_hash') ? $self->get_goal_value->to_hash(@_) : $self->get_goal_value
  };
  if ($cb->allow_group('activity')) {
    $r->{activities} = [
      map {$_->activity->to_hash(@_, goals => $FALSE)}
      grep {$cb->allow('activity', $_->activity)} $self->user_goal_fulfillment_activities->ordered('-desc')
    ];
  }
  return $r;
}

1;

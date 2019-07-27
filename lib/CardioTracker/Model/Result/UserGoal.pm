use utf8;
package CardioTracker::Model::Result::UserGoal;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CardioTracker::Model::Result::UserGoal

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

=head1 TABLE: C<user_goal>

=cut

__PACKAGE__->table("user_goal");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 goal_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "goal_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<fk_user_goal_user_goal1_uniq>

=over 4

=item * L</user_id>

=item * L</goal_id>

=back

=cut

__PACKAGE__->add_unique_constraint("fk_user_goal_user_goal1_uniq", ["user_id", "goal_id"]);

=head1 RELATIONS

=head2 goal

Type: belongs_to

Related object: L<CardioTracker::Model::Result::Goal>

=cut

__PACKAGE__->belongs_to(
  "goal",
  "CardioTracker::Model::Result::Goal",
  { id => "goal_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user

Type: belongs_to

Related object: L<CardioTracker::Model::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "CardioTracker::Model::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user_goal_fulfillments

Type: has_many

Related object: L<CardioTracker::Model::Result::UserGoalFulfillment>

=cut

__PACKAGE__->has_many(
  "user_goal_fulfillments",
  "CardioTracker::Model::Result::UserGoalFulfillment",
  { "foreign.user_goal_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-07-27 12:13:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oR2u4XufIMjFJbYR5/054w


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use List::Util qw(reduce);
use DateTime::Format::Duration;

sub recalculate {
  my $self=shift;

  #print STDERR "recalculating '".$self->goal->name."' for ".$self->user->username."\n";

  $self->delete_related('user_goal_activities');
  if($self->goal->goal_comparator->is_superlative) {
    $self->_calculate_pr();
  } else {
    $self->_calculate_goal();
  }
  print $self->goal->name .": ". $self->get_goal_description . "\n";
}

sub _get_pr_rs {
  my $self = shift;
  my $act_rs = $self->user->activities->by_type($self->goal->activity_type)->search({},{
    join => [
      'result',
      {distance => 'uom' },
    ]
  });
  $act_rs = $act_rs->search({ event_id => {'!=', undef} }) if($self->goal->event_only eq 'Y');
  if(defined($self->goal->min_distance) && defined($self->goal->max_distance) && $self->goal->min_distance->id == $self->goal->max_distance->id) {
    $act_rs = $act_rs->near_distance($self->goal->min_distance);
  } else {
    $act_rs = $act_rs->min_distance($self->goal->min_distance) if(defined($self->goal->min_distance));
    $act_rs = $act_rs->max_distance($self->goal->max_distance) if(defined($self->goal->max_distance));
  }
  $act_rs = $act_rs->after_date($self->goal->min_date) if(defined($self->goal->min_date));
  $act_rs = $act_rs->before_date($self->goal->max_date) if(defined($self->goal->max_date));
  return $act_rs;
}

sub _calculate_pr {
  my $self = shift;
  # Selection; Type, Min Distance, Max Distance
  # Projection: Dimension
  # Ordering: Comparator
  # Grouping: Span

  my %dimension_field_map = (
    distance => \["distance.value * uom.conversion_factor"],
    time     => 'result.net_time',
    pace     => 'result.pace',
    speed    => \["1/((HOUR(result.pace)*60*60+MINUTE(result.pace)*60+SECOND(result.pace))/(60*60))"]
  );
  my %dimension_aggregation_map = (
    distance => \["SUM(distance.value * uom.conversion_factor)"],
    time     => \['SUM(result.net_time)'],
  );

  my %span_unit_map = (
    day => [qw(YEAR DAYOFYEAR)],
    week => [qw(YEAR WEEK)],
    month => [qw(YEAR MONTH)],
    year => [qw(YEAR)]
  );

  my %map = defined($self->goal->goal_span) ? %dimension_aggregation_map : %dimension_field_map;

  my $act_rs = $self->_get_pr_rs->search({},{
    order_by => { $self->goal->goal_comparator->order_by => $map{$self->goal->dimension->description} },
    rows => 1
  });
  if(defined($self->goal->goal_span)) {
    my @group = map { \["$_(start_time)"] } @{$span_unit_map{$self->goal->goal_span->description}};
    my $a = $act_rs->search({},{
      group_by => \@group,
    })->first;

    my @search = map { \["$_(start_time) = (SELECT $_(start_time) FROM activity WHERE id = ?)" => $a->id] } @{$span_unit_map{$self->goal->goal_span->description}};
    $act_rs = $self->_get_pr_rs->search({
      -and => \@search
    },{});
  }

  foreach ($act_rs->all) {
    $self->add_to_user_goal_activities({ user_goal_id => $self->id, activity_id => $_->id });
  }
}

sub get_goal_value {
  my $self = shift;
  my $d = $self->goal->dimension->description;
  my %dimension_lookup_map = (
    time     => sub {shift->result->net_time},
    pace     => sub {shift->result->pace},
    distance => sub {shift->distance},
    speed    => sub {shift->result->speed}
  );

  my %aggregation_lookup_map = (
    time     => sub { reduce { $a->add($b) } @_ },
    distance => sub {
      my $v = reduce { $a+$b } map { $_->normalized_value } @_;
      my $schema = $self->result_source->schema;
      return $schema->resultset('Distance')->new_result({
        value => $v,
        uom   => $schema->resultset('UnitOfMeasure')->normalization_unit('distance')
      })
    }
  );

  my $act_rs = $self->user_goal_activities;
  my $lu = $dimension_lookup_map{$d};
  if(defined($self->goal->goal_span)) {
    my @v = map { $lu->($_->activity) } $act_rs->all;
    return $aggregation_lookup_map{$d}->(@v);
  } else {
    return $lu->($act_rs->first->activity);
  }
}

sub get_goal_description {
  my $self = shift;
  my $tf = DateTime::Format::Duration->new(pattern => '%T', normalize => 1);
  my %dimension_desc_map = (
    time => sub { $tf->format_duration(shift) },
    pace => sub { $tf->format_duration(shift) },
    distance => sub { shift->description },
    speed => sub { sprintf('%.02f', $_[0]->{value}) ." ". $_[0]->{units}->abbreviation }
  );

  my $desc = $dimension_desc_map{$self->goal->dimension->description};
  return $desc->($self->get_goal_value);
}

1;

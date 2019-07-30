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

sub _dimension_field_map {
  (
    distance => 'distance.value * uom.conversion_factor',
    time     => 'result.net_time',
    pace     => 'result.pace',
    speed    => '1/((HOUR(result.pace)*60*60+MINUTE(result.pace)*60+SECOND(result.pace))/(60*60))'
  )
}

sub _dimension_value_map {
  (
    distance => sub { shift->distance->normalized_value },
    time => sub { DateTime::Format::Duration->new(pattern => '%T')->format_duration(shift->time) },
    pace => sub { DateTime::Format::Duration->new(pattern => '%T')->format_duration(shift->time) }
  )
}

sub _dimension_aggregation_map {
  (
    distance => 'SUM(distance.value * uom.conversion_factor)',
    time     => 'SUM(result.net_time)',
  )
}

sub _goal_span_map {
  (
    day => [qw(YEAR MONTH DAYOFMONTH)],
    week => [qw(YEAR WEEK)],
    month => [qw(YEAR MONTH)],
    year => [qw(YEAR)]
  )
}

sub recalculate {
  my $self = shift;

  foreach my $ugf ($self->user_goal_fulfillments) {
    $ugf->delete_related('user_goal_fulfillment_activities');
    $ugf->delete;
  }

  foreach ($self->user->activities->by_type($self->goal->activity_type)->ordered) {
    $self->update($_);
  }
}

sub is_pr {
  shift->goal->goal_comparator->is_superlative
}

sub update {
  my $self=shift;
  my ($activity) = @_;

  if($self->is_pr) {
    $self->_calculate_pr($activity);
  } elsif(!$self->is_fulfilled) {
    $self->_calculate_achievement($activity);
  }
}

sub _calculate_achievement {
  my $self = shift;
  my ($activity) = @_;

  my %fmap = defined($self->goal->goal_span) ? _dimension_aggregation_map : _dimension_field_map;
  my %vmap = _dimension_value_map;
  my %span_unit_map = _goal_span_map;

  my $act_rs = $self->_get_rs->ordered('-asc')->search({
    start_time => {'<=' => DateTime::Format::MySQL->format_datetime($activity->start_time) },
  });
  
  my $cond = \[sprintf($fmap{$self->goal->dimension->description}.' %s ?', $self->goal->goal_comparator->operator) => $vmap{$self->goal->dimension->description}->($self->goal)];


  if(defined($self->goal->goal_span)) {
    my @group = map { \["$_(start_time)"] } @{$span_unit_map{$self->goal->goal_span->description}};
    my $a = $act_rs->search({},{
      group_by => \@group,
      having => $cond
    })->first;
    return unless(defined($a));

    my @search = map { \["$_(start_time) = (SELECT $_(start_time) FROM activity WHERE id = ?)" => $a->id] } @{$span_unit_map{$self->goal->goal_span->description}};
    $act_rs = $self->_get_rs->search({
      start_time => {'<=' => DateTime::Format::MySQL->format_datetime($activity->start_time) },
      -and => \@search
    },{});
  } else {
    $act_rs = $act_rs->search({
      '-and' => [$cond]
    });
  }
  return unless($act_rs->count);

  # Create new activity set
  my $ugf = $self->create_related('user_goal_fulfillments', { date => DateTime::Format::MySQL->format_datetime($act_rs->ordered('-desc')->first->start_time) });
  while(my $a = $act_rs->next) {
    $ugf->add_to_user_goal_fulfillment_activities({ user_goal_fulfillment_id => $ugf->id, activity_id => $a->id });
  }
}

sub _get_rs {
  my $self = shift;
  my $act_rs = $self->user->activities->whole_or_event->by_type($self->goal->activity_type)->search({},{
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
  my ($activity) = @_;

  my %span_unit_map = _goal_span_map;
  my %map = defined($self->goal->goal_span) ? _dimension_aggregation_map : _dimension_field_map;

  my $act_rs = $self->_get_rs->search({
    start_time => {'<=' => DateTime::Format::MySQL->format_datetime($activity->start_time) }
  },{
    order_by => { $self->goal->goal_comparator->order_by => \[$map{$self->goal->dimension->description}] },
    rows => 1
  });
  if(defined($self->goal->goal_span)) {
    my @group = map { \["$_(start_time)"] } @{$span_unit_map{$self->goal->goal_span->description}};
    my $a = $act_rs->search({},{
      group_by => \@group,
    })->first;

    my @search = map { \["$_(start_time) = (SELECT $_(start_time) FROM activity WHERE id = ?)" => $a->id] } @{$span_unit_map{$self->goal->goal_span->description}};
    $act_rs = $self->_get_rs->search({
      start_time => {'<=' => DateTime::Format::MySQL->format_datetime($activity->start_time) },
      -and => \@search
    },{});
  }
  # No Matching Results
  unless($act_rs->count) {
    # print "No matching results\n";
    return;
  }

  my @r = sort { DateTime->compare($a->start_time,$b->start_time) } $act_rs->all;
  my $ugf;
  if($ugf = $self->user_goal_fulfillments->most_recent) {
    if($ugf->user_goal_fulfillment_activities->ordered('-desc')->first->activity->start_time >= $r[-1]->start_time) {
      # print "No New Results\n";
      return;
    } 
  }

  # Create new activity set
  $ugf = $self->create_related('user_goal_fulfillments', { date => DateTime::Format::MySQL->format_datetime($r[-1]->start_time) });
  foreach (@r) {
    $ugf->add_to_user_goal_fulfillment_activities({ user_goal_fulfillment_id => $ugf->id, activity_id => $_->id });
  }
  # print $self->goal->name .': '.$ugf->get_goal_description." (".$ugf->date->strftime('%F').")\n";
}

sub is_fulfilled {
  shift->user_goal_fulfillments->count > 0;
}

sub history {
  my $self = shift;

  return $self->user_goal_fulfillments->ordered;
}

sub get_goal_value {
  my $self = shift;
  
  return $self->user_goal_fulfillments->most_recent->get_goal_value;
}

sub get_goal_description {
  my $self = shift;

  return $self->user_goal_fulfillments->most_recent->get_goal_description;
}

1;

#<<<
use utf8;
package Moove::Model::Result::UserGoal;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::UserGoal

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

=head1 TABLE: C<UserGoal>

=cut

__PACKAGE__->table("UserGoal");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 subscribed

  data_type: 'enum'
  default_value: 'N'
  extra: {list => ["Y","N"]}
  is_nullable: 0

=head2 goal_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "subscribed",
  {
    data_type => "enum",
    default_value => "N",
    extra => { list => ["Y", "N"] },
    is_nullable => 0,
  },
  "goal_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
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

=head2 goal

Type: belongs_to

Related object: L<Moove::Model::Result::Goal>

=cut

__PACKAGE__->belongs_to(
  "goal",
  "Moove::Model::Result::Goal",
  { id => "goal_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user

Type: belongs_to

Related object: L<Moove::Model::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Moove::Model::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user_goal_fulfillments

Type: has_many

Related object: L<Moove::Model::Result::UserGoalFulfillment>

=cut

__PACKAGE__->has_many(
  "user_goal_fulfillments",
  "Moove::Model::Result::UserGoalFulfillment",
  { "foreign.user_goal_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>
use experimental qw(signatures postderef);

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-04-02 11:05:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ysM9O71AL2RSzOCu1RKvVA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use List::Util qw(reduce);
use DateTime::Format::Duration;

sub _dimension_field_map {
  (
    distance => 'distance.value * uom.conversion_factor',
    time     => 'result.net_time',
    pace     => 'result.pace',
    speed    => 'result.speed'
  );
}

sub _dimension_value_map {
  (
    distance => sub {shift->distance->normalized_value},
    speed    => sub {shift->distance->normalized_value},
    time     => sub {DateTime::Format::Duration->new(pattern => '%T')->format_duration(shift->time)},
    pace     => sub {DateTime::Format::Duration->new(pattern => '%T')->format_duration(shift->time)}
  );
}

sub _dimension_aggregation_map {
  (
    distance => 'SUM(distance.value * uom.conversion_factor)',
    time     => 'SUM(result.net_time)',
  );
}

sub recalculate {
  my $self = shift;

  foreach my $ugf ($self->user_goal_fulfillments) {
    $ugf->delete_related('user_goal_fulfillment_activities');
    $ugf->delete;
  }

  foreach ($self->user->activities->activity_type($self->goal->activity_type)->whole_or_event->ordered) {
    $self->update($_);
  }
}

sub update {
  my $self = shift;
  my ($activity) = @_;

  if ($self->goal->is_pr) {
    $self->_calculate_pr($activity);
  } elsif (!$self->is_fulfilled) {
    $self->_calculate_achievement($activity);
  }
}

sub _calculate_achievement {
  my $self = shift;
  my ($activity) = @_;

  my %fmap = defined($self->goal->goal_span) ? _dimension_aggregation_map : _dimension_field_map;
  my %vmap = _dimension_value_map;

  my $act_rs = $self->_get_rs->ordered('-asc')->search(
    {
      start_time => {'<=' => DateTime::Format::MySQL->format_datetime($activity->start_time)},
    }
  );

  my $cond = \[
    sprintf($fmap{$self->goal->dimension->description} . ' %s ?', $self->goal->goal_comparator->operator) =>
      $vmap{$self->goal->dimension->description}->($self->goal)
  ];

  if (defined($self->goal->goal_span)) {
    my $a = $act_rs->search(
      {},
      {
        group_by => [map {\["$_(start_time)"]} @{$self->goal->goal_span->sql_comp_func}],
        having   => $cond
      }
    )->first;
    return unless (defined($a));

    my @search = map {\["$_(start_time) = (SELECT $_(start_time) FROM activity WHERE id = ?)" => $a->id]}
      @{$self->goal->goal_span->sql_comp_func};
    $act_rs = $self->_get_rs->search(
      {
        start_time => {'<=' => DateTime::Format::MySQL->format_datetime($activity->start_time)},
        -and       => \@search
      },
      {}
    );
  } else {
    $act_rs = $act_rs->search(
      {
        '-and' => [$cond]
      }
    );
  }
  return unless ($act_rs->count);

  # Create new activity set
  foreach ($self->user_goal_fulfillments) {
    $_->update({is_current => 'N'});
  }
  my $ugf = $self->create_related('user_goal_fulfillments',
    {date => DateTime::Format::MySQL->format_datetime($act_rs->ordered('-desc')->first->start_time)});
  while (my $a = $act_rs->next) {
    $ugf->add_to_user_goal_fulfillment_activities({user_goal_fulfillment_id => $ugf->id, activity_id => $a->id});
  }
}

sub _get_rs {
  my $self   = shift;
  my $act_rs = $self->user->activities->whole_or_event->activity_type($self->goal->activity_type)->search(
    {},
    {
      join => ['result', {distance => 'uom'},]
    }
  );
  $act_rs = $act_rs->search({event_id => {'!=', undef}}) if ($self->goal->event_only eq 'Y');
  if ( defined($self->goal->min_distance)
    && defined($self->goal->max_distance)
    && $self->goal->min_distance->id == $self->goal->max_distance->id)
  {
    $act_rs = $act_rs->near_distance($self->goal->min_distance);
  } else {
    $act_rs = $act_rs->min_distance($self->goal->min_distance) if (defined($self->goal->min_distance));
    $act_rs = $act_rs->max_distance($self->goal->max_distance) if (defined($self->goal->max_distance));
  }
  $act_rs = $act_rs->after_date($self->goal->min_date)  if (defined($self->goal->min_date));
  $act_rs = $act_rs->before_date($self->goal->max_date) if (defined($self->goal->max_date));
  return $act_rs;
}

sub _calculate_pr {
  my $self = shift;
  my ($activity) = @_;

  my %map = defined($self->goal->goal_span) ? _dimension_aggregation_map : _dimension_field_map;

  my $act_rs = $self->_get_rs->search(
    {
      start_time => {'<=' => DateTime::Format::MySQL->format_datetime($activity->start_time)}
    }, {
      order_by => {$self->goal->goal_comparator->order_by => \[$map{$self->goal->dimension->description}]},
      rows     => 1
    }
  );
  if (defined($self->goal->goal_span)) {
    my @group = map {\["$_(start_time)"]} @{$self->goal->goal_span->sql_comp_func};
    $act_rs = $act_rs->search(
      {},
      {
        group_by => \@group,
      }
    );
    return if ($act_rs->ordered('-desc')->first->start_time > $activity->start_time);

    my @search = map {\["$_(start_time) = (SELECT $_(start_time) FROM activity WHERE id = ?)" => $act_rs->first->id]}
      @{$self->goal->goal_span->sql_comp_func};
    $act_rs = $self->_get_rs->search(
      {
        start_time => {'<=' => DateTime::Format::MySQL->format_datetime($activity->start_time)},
        -and       => \@search
      },
      {}
    );
  }
  unless ($act_rs->count) {
    return;
  }

  my @r = sort {DateTime->compare($a->start_time, $b->start_time)} $act_rs->all;
  my $ugf;
  if ($ugf = $self->user_goal_fulfillments->most_recent) {
    return if ($ugf->user_goal_fulfillment_activities->ordered('-desc')->first->activity->start_time >= $r[-1]->start_time);
  }

  # Create new activity set
  foreach ($self->user_goal_fulfillments) {
    $_->update({is_current => 'N'});
  }
  $ugf = $self->create_related('user_goal_fulfillments', {date => DateTime::Format::MySQL->format_datetime($r[-1]->start_time)});
  foreach (@r) {
    $ugf->add_to_user_goal_fulfillment_activities({user_goal_fulfillment_id => $ugf->id, activity_id => $_->id});
  }
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

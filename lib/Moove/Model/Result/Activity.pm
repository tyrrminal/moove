#<<<
use utf8;
package Moove::Model::Result::Activity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Moove::Model::Result::Activity

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

=head1 TABLE: C<activity>

=cut

__PACKAGE__->table("activity");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 activity_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 start_time

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 distance_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 result_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 event_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 temperature

  data_type: 'decimal'
  is_nullable: 1
  size: [4,1]

=head2 note

  data_type: 'mediumtext'
  is_nullable: 1

=head2 whole_activity_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "activity_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "start_time",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "distance_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "result_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "event_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "temperature",
  { data_type => "decimal", is_nullable => 1, size => [4, 1] },
  "note",
  { data_type => "mediumtext", is_nullable => 1 },
  "whole_activity_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
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
  { "foreign.whole_activity_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 activity_points

Type: has_many

Related object: L<Moove::Model::Result::ActivityPoint>

=cut

__PACKAGE__->has_many(
  "activity_points",
  "Moove::Model::Result::ActivityPoint",
  { "foreign.activity_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 activity_references

Type: has_many

Related object: L<Moove::Model::Result::ActivityReference>

=cut

__PACKAGE__->has_many(
  "activity_references",
  "Moove::Model::Result::ActivityReference",
  { "foreign.activity_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 activity_type

Type: belongs_to

Related object: L<Moove::Model::Result::ActivityType>

=cut

__PACKAGE__->belongs_to(
  "activity_type",
  "Moove::Model::Result::ActivityType",
  { id => "activity_type_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 distance

Type: belongs_to

Related object: L<Moove::Model::Result::Distance>

=cut

__PACKAGE__->belongs_to(
  "distance",
  "Moove::Model::Result::Distance",
  { id => "distance_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 event

Type: belongs_to

Related object: L<Moove::Model::Result::Event>

=cut

__PACKAGE__->belongs_to(
  "event",
  "Moove::Model::Result::Event",
  { id => "event_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 result

Type: belongs_to

Related object: L<Moove::Model::Result::Result>

=cut

__PACKAGE__->belongs_to(
  "result",
  "Moove::Model::Result::Result",
  { id => "result_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 user

Type: belongs_to

Related object: L<Moove::Model::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Moove::Model::Result::User",
  { id => "user_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 user_goal_fulfillment_activities

Type: has_many

Related object: L<Moove::Model::Result::UserGoalFulfillmentActivity>

=cut

__PACKAGE__->has_many(
  "user_goal_fulfillment_activities",
  "Moove::Model::Result::UserGoalFulfillmentActivity",
  { "foreign.activity_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 whole_activity

Type: belongs_to

Related object: L<Moove::Model::Result::Activity>

=cut

__PACKAGE__->belongs_to(
  "whole_activity",
  "Moove::Model::Result::Activity",
  { id => "whole_activity_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 user_goal_fulfillments

Type: many_to_many

Composing rels: L</user_goal_fulfillment_activities> -> user_goal_fulfillment

=cut

__PACKAGE__->many_to_many(
  "user_goal_fulfillments",
  "user_goal_fulfillment_activities",
  "user_goal_fulfillment",
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-08-02 13:17:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:v9GZXy0RurzGX0lM3hpj0w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
use DCS::Constants qw(:boolean);
use List::Util qw(max);

use InclusionCallback;

use Moose;
use MooseX::NonMoose;

sub description {
  my $self = shift;

  return sprintf('%s %s %s', $self->start_time->strftime('%F'), $self->distance->description, $self->activity_type->description);
}

sub has_event_visible_to {
  my $self = shift;
  my ($user) = @_;

  return $FALSE unless (defined($self->event));
  return $self->result_source->schema->resultset('EventRegistration')->search(
    {
      -and => [
        'event_id' => $self->event_id,
        -or        => [
          is_public => 'Y',
          user_id   => $user->id
        ]
      ]
    }
  )->count > 0;
}

around 'note' => sub {
  my $orig = shift;
  my $self = shift;

  my $v = $self->$orig(@_) // '';
  $v =~ s/\s*$//m;
  $v =~ s/^\s*//m;
  return $v;
};

sub is_outdoor_activity {
  return shift->activity_type->description ne 'Treadmill';
}

sub is_running_activity {
  my $self = shift;
  return $self->activity_type->description eq 'Run' || $self->activity_type->description eq 'Treadmill';
}

sub is_cycling_activity {
  return shift->activity_type->description eq 'Ride';
}

sub end_time {
  my $self = shift;

  return $self->start_time unless (defined($self->result));
  return $self->start_time + ($self->result->gross_time // $self->result->net_time);
}

sub first_activity_point {
  my $self = shift;

  return $self->activity_points->search(
    {},
    {
      order_by => {'-asc' => 'timestamp'}
    }
  )->first;
}

sub last_activity_point {
  my $self = shift;

  return $self->activity_points->search(
    {},
    {
      order_by => {'-desc' => 'timestamp'}
    }
  )->first;
}

sub to_hash {
  my $self = shift;
  my $cb   = InclusionCallback->new(@_);

  my $a = {
    id            => $self->id,
    activity_type => $self->activity_type->to_hash(@_),
    distance      => $self->distance->to_hash(@_),
    temperature   => $self->temperature,
    note          => $self->note,
  };
  $a->{start_time}     = $self->start_time->to_hash(@_)     if (defined($self->start_time));
  $a->{result}         = $self->result->to_hash(@_)         if (defined($self->result));
  $a->{event}          = $self->event->to_hash(@_)          if ($cb->allow('event', $self->event));
  $a->{whole_activity} = $self->whole_activity->to_hash(@_) if (defined($self->whole_activity));

  if ($cb->allow_group('goal')) {
    my @record_fulfillments =
      grep {$cb->allow('goal', $_)}
      grep {$_->most_recent_activity->id == $self->id}
      grep {$_->user_goal->goal->is_pr} $self->user_goal_fulfillments;
    $a->{records} = [
      map {
        $_->user_goal->to_hash(@_, fulfillment => sub {shift->id == $_->id})
        } @record_fulfillments
      ]
      if (@record_fulfillments);

    my @ach_fulfillments =
      grep {$cb->allow('goal', $_)}
      grep {!$_->user_goal->goal->is_pr} $self->user_goal_fulfillments;
    $a->{achievements} = [
      map {
        $_->user_goal->to_hash(@_, fulfillment => sub {shift->id == $_->id})
        } @ach_fulfillments
      ]
      if (@ach_fulfillments);
  }

  return $a;
}

1;
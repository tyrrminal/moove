package Moove::Model::ResultSet::UserEventActivity;
use strict;
use warnings;

use base qw(DBIx::Class::ResultSet);

use DateTime::Format::MySQL;

use experimental qw(signatures postderef);

sub on_or_before($self, $date) {
  return $self->search({
    'event_activity.scheduled_start' =>  {'<' => DateTime::Format::MySQL->format_date($date->clone->add(days => 1))}
  },{
    join => {event_registration => 'event_activity'},
  })
}

sub on_or_after($self, $date) {
  return $self->search({
    'event_activity.scheduled_start' => {'>=' => DateTime::Format::MySQL->format_date($date)}
  },{
    join => {event_registration => 'event_activity'},
  })
}

sub before ($self, $event) {
  return $self->search(
    {
      'event.scheduled_start' => {'<' => DateTime::Format::MySQL->format_datetime($event->scheduled_start)}
    }, {
      join => 'event'
    }
  )->ordered('-desc');
}

sub after ($self, $event) {
  return $self->search(
    {
      'event.scheduled_start' => {'>' => DateTime::Format::MySQL->format_datetime($event->scheduled_start)}
    }, {
      join => 'event'
    }
  )->ordered('-asc');
}

sub in_sequence ($self, $sequence_id) {
  return $self->search(
    {
      '-and' => [{'event_group.event_sequence_id' => $sequence_id}, {'event_group.event_sequence_id' => {'<>' => undef}}]
    }, {
      join => {event => 'event_group'}
    }
  );
}

sub in_series ($self, $series_id) {
  return $self->search(
    {
      'event_group_series.event_series_id' => $series_id
    }, {
      join => {event => {event_group => 'event_group_series'}}
    }
  );
}

sub for_user ($self, $user) {
  return $self->search(
    {
      user_id => $user->id
    }
  );
}

sub visible_to ($self, $user) {
  return $self->search(
    {
      -or => [
        {visibility_type_id => 3},
        {user_id  => $user->id},
        {
          -and => [{visibility_type_id => 2}, {'friendship_initiators.receiver_id' => $user->id}]
        }
      ]
    }, {
      join => {user => 'friendship_initiators'}
    }
  );
}

sub ordered ($self, $direction = '-asc') {
  return $self->search(
    {},
    {
      join     => 'event',
      order_by => {$direction => 'event.scheduled_start'}
    }
  );
}

sub past($self) {
  return $self->search(
    {
      'event.scheduled_start' => {'<=' => DateTime::Format::MySQL->format_datetime(DateTime->now(time_zone => 'local'))}
    }, {
      join => 'event'
    }
  );
}

sub future($self) {
  return $self->search(
    {
      'event.scheduled_start' => {'>' => DateTime::Format::MySQL->format_datetime(DateTime->now(time_zone => 'local'))}
    }, {
      join => 'event'
    }
  );
}

sub year ($self, $year) {
  return $self->search(
    {
      -and => [\['YEAR(event.scheduled_start)=?', $year]]
    }, {
      join => 'event'
    }
  );
}

1;

package Moove::Model::ResultSet::UserEventActivity;
use strict;
use warnings;

use base qw(DBIx::Class::ResultSet);

use DateTime::Format::MySQL;

use experimental qw(signatures postderef);

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

sub visible($self) {
  return $self->search(
    {
      -or => [
        is_public => 'Y',
        user_id   => $self->stash->{uid}
      ]
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

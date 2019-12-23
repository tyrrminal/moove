package Moove::Model::ResultSet::EventRegistration;

use base qw(DBIx::Class::ResultSet);

use DateTime::Format::MySQL;

sub before {
  my $self = shift;
  my ($event) = @_;

  return $self->search(
    {
      'event.scheduled_start' => {'<' => DateTime::Format::MySQL->format_datetime($event->scheduled_start)}
    }, {
      join => 'event'
    }
  )->ordered('-desc');
}

sub after {
  my $self = shift;
  my ($event) = @_;

  return $self->search(
    {
      'event.scheduled_start' => {'>' => DateTime::Format::MySQL->format_datetime($event->scheduled_start)}
    }, {
      join => 'event'
    }
  )->ordered('-asc');
}

sub in_sequence {
  my $self = shift;
  my ($sequence_id) = @_;

  return $self->search(
    {
      '-and' => [{'event_group.event_sequence_id' => $sequence_id}, {'event_group.event_sequence_id' => {'<>' => undef}}]
    }, {
      join => {event => 'event_group'}
    }
  );
}

sub in_series {
  my $self = shift;
  my ($series_id) = @_;

  return $self->search(
    {
      'event_group_series.event_series_id' => $series_id
    }, {
      join => {event => {event_group => 'event_group_series'}}
    }
  );
}

sub for_user {
  my $self = shift;
  my ($user) = @_;

  return $self->search(
    {
      user_id => $user->id
    }
  );
}

sub visible_to {
  my $self = shift;
  my ($user) = @_;

  return $self->search(
    {
      -or => [
        is_public => 'Y',
        user_id   => $user->id
      ]
    }
  );
}

sub ordered {
  my $self = shift;
  my ($direction) = (@_, '-asc');

  return $self->search(
    {},
    {
      join     => 'event',
      order_by => {$direction => 'event.scheduled_start'}
    }
  );
}

sub past {
  my $self = shift;

  return $self->search(
    {
      'event.scheduled_start' => {'<=' => DateTime::Format::MySQL->format_datetime(DateTime->now(time_zone => 'local'))}
    }, {
      join => 'event'
    }
  );
}

sub future {
  my $self = shift;

  return $self->search(
    {
      'event.scheduled_start' => {'>' => DateTime::Format::MySQL->format_datetime(DateTime->now(time_zone => 'local'))}
    }, {
      join => 'event'
    }
  );
}

sub year {
  my $self = shift;
  my ($year) = @_;

  return $self->search(
    {
      -and => [\['YEAR(event.scheduled_start)=?', $year]]
    }, {
      join => 'event'
    }
  );
}

1;

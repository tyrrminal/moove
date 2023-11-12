package Moove::Model::ResultSet::UserEventActivity;
use v5.38;

use base qw(DBIx::Class::ResultSet);

__PACKAGE__->load_components(qw{Helper::ResultSet::SetOperations});

use DateTime::Format::MySQL;

sub on_or_before ($self, $date) {
  return $self->search(
    {
      'event_activity.scheduled_start' => {'<' => DateTime::Format::MySQL->format_date($date->clone->add(days => 1))}
    }, {
      join => {event_registration => 'event_activity'},
    }
  );
}

sub on_or_after ($self, $date) {
  return $self->search(
    {
      'event_activity.scheduled_start' => {'>=' => DateTime::Format::MySQL->format_date($date)}
    }, {
      join => {event_registration => 'event_activity'},
    }
  );
}

sub before ($self, $event) {
  return $self->search(
    {
      'event_activity.scheduled_start' =>
        {'<' => DateTime::Format::MySQL->format_datetime($event->event_registration->event_activity->scheduled_start)}
    }, {
      join => {event_registration => 'event_activity'},
    }
  )->ordered('-desc');
}

sub after ($self, $event) {
  return $self->search(
    {
      'event_activity.scheduled_start' =>
        {'>' => DateTime::Format::MySQL->format_datetime($event->event_registration->event_activity->scheduled_start)}
    }, {
      join => {event_registration => 'event_activity'},
    }
  )->ordered('-asc');
}

sub in_group ($self, $event_group_id) {
  my $eg_rs = $self->search(
    {
      'event.event_group_id' => $event_group_id,
    }, {
      join => {event_registration => {event_activity => 'event'}},
    }
  );
  my $es_rs = $self->search(
    {
      'event_series.id' => $event_group_id
    }, {
      join => {event_registration => {event_activity => {event => {event_series_events => 'event_series'}}}}
    }
  );
  return $eg_rs->union($es_rs);
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
        {user_id            => $user->id},
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
    undef, {
      join     => {event_registration => 'event_activity'},
      order_by => {$direction         => 'event_activity.scheduled_start'}
    }
  );
}

sub past ($self) {
  return $self->search(
    {
      'event.scheduled_start' => {'<=' => DateTime::Format::MySQL->format_datetime(DateTime->now(time_zone => 'local'))}
    }, {
      join => 'event'
    }
  );
}

sub future ($self) {
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

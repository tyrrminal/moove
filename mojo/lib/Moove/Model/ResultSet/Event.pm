package Moove::Model::ResultSet::Event;
use v5.38;

use base qw(DBIx::Class::ResultSet);

use DateTime;
use DateTime::Format::MySQL;

sub find_event ($self, $year, $name) {
  return $self->by_name($name)->in_year($year)->first;
}

sub in_year ($self, $year) {
  my $d = DateTime->new(year => $year, month => 1, day => 1);
  return $self->search(
    {
      'event_activities.scheduled_start' =>
        {-between => [DateTime::Format::MySQL->format_date($d), DateTime::Format::MySQL->format_date($d->clone->add(years => 1))]}
    }, {
      join     => 'event_activities',
      collapse => 1
    }
  );
}

sub by_name ($self, $name) {
  my $str = "%${name}%";
  return $self->search(
    {
      -or => [{'me.name' => {-like => $str}}, {'event_group.name' => {-like => $str}}]
    }, {
      join => 'event_group'
    }
  );
}

sub for_user ($self, $user) {
  return $self->search(
    {
      'event_registrations.user_id' => $user->id
    }, {
      join => 'event_registrations'
    }
  );
}

sub of_type ($self, $type) {
  return $self->search(
    {
      'event_type.activity_type_id' => $type->id
    }, {
      join => 'event_type'
    }
  );
}

sub on_or_before ($self, $date) {
  return $self->search(
    {
      'event_activities.scheduled_start' => {'<' => DateTime::Format::MySQL->format_date($date->clone->add(days => 1))}
    }, {
      join     => 'event_activities',
      collapse => 1
    }
  );
}

sub on_or_after ($self, $date) {
  return $self->search(
    {
      'event_activities.scheduled_start' => {'>=' => DateTime::Format::MySQL->format_date($date)}
    }, {
      join     => 'event_activities',
      collapse => 1
    }
  );
}

sub on_date ($self, $date) {
  return $self->search(
    {
      'event_activities.scheduled_start' => {
        -between =>
          [DateTime::Format::MySQL->format_date($date), DateTime::Format::MySQL->format_date($date->clone->add(days => 1))]
      }
    }, {
      join     => 'event_activities',
      collapse => 1
    }
  );
}

sub near_datetime ($self, $date, $minutes_before, $minutes_after) {
  my $before = $date->clone->subtract(minutes => $minutes_before);
  my $after  = $date->clone->add(minutes => $minutes_after);

  return $self->search(
    {
      scheduled_start =>
        {-between => [DateTime::Format::MySQL->format_datetime($before), DateTime::Format::MySQL->format_datetime($after)]}
    }
  );
}

sub is_missing_gender_group ($self) {
  $self->search(
    \["
    me.id IN (
      SELECT e.id 
      FROM `event` e
      JOIN gender g
      WHERE NOT EXISTS (
        SELECT *
          FROM event_result_group erg
          WHERE erg.event_id=e.id
          AND erg.gender_id=g.id
          AND erg.division_id IS NULL
      )
    )
  "
    ]
  );
}

1;
